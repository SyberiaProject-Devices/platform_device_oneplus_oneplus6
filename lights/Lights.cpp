/*
 * Copyright (C) 2019 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "Lights.h"

#include <android-base/logging.h>
#include <log/log.h>
#include <android-base/stringprintf.h>
#include <fstream>

namespace aidl {
namespace android {
namespace hardware {
namespace light {

/*
 * Write value to path and close file.
 */
template <typename T>
static void set(const std::string& path, const T& value) {
    std::ofstream file(path);
    file << value;
}

template <typename T>
static T get(const std::string& path, const T& def) {
    std::ifstream file(path);
    T result;

    file >> result;
    return file.fail() ? def : result;
}

const static std::map<LightType, int> kSupportedLights = {
    {LightType::BACKLIGHT, 3},
    {LightType::BATTERY, 2},
    {LightType::NOTIFICATIONS, 1},
    {LightType::ATTENTION, 0}
};

Lights::Lights() {
    for (auto const &pair : kSupportedLights) {
        LightType type = pair.first;
        int priority = pair.second;
        HwLight hwLight{};
        hwLight.id = (int)type;
        hwLight.type = type;
        hwLight.ordinal = 0;
        mLights[hwLight.id] = priority;
        mAvailableLights.emplace_back(hwLight);
    }
}

ndk::ScopedAStatus Lights::setLightState(int id, const HwLightState& state) {
    ALOGI("setLightState id=%d", id);
    auto it = mLights.find(id);
    if (it == mLights.end()) {
        ALOGE("Light not supported");
        return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
    }
    if (id == (int)LightType::BACKLIGHT) {
        ALOGD("Do nothing for screen backlight brightness.");
        return ndk::ScopedAStatus::ok();
    }

    std::lock_guard<std::mutex> lock(mLock);

    mLightStates.at(mLights[id]) = state;

    HwLightState stateToUse = mLightStates.front();
    for (const auto& lightState : mLightStates) {
        if (lightState.color & 0xffffff) {
            stateToUse = lightState;
            break;
        }
    }

    std::map<std::string, int> colorValues;
    colorValues["red"] = (stateToUse.color >> 16) & 0xff;
    // lower green and blue brightness to adjust for the (lower) brightness of red
    colorValues["green"] = ((stateToUse.color >> 8) & 0xff) / 2;
    colorValues["blue"] = (stateToUse.color & 0xff) / 2;

    int onMs = stateToUse.flashMode == FlashMode::TIMED ? stateToUse.flashOnMs : 0;
    int offMs = stateToUse.flashMode == FlashMode::TIMED ? stateToUse.flashOffMs : 0;

    // LUT has 63 entries, we could theoretically use them as 3 (colors) * 21 (steps).
    // However, the last LUT entries don't seem to behave correctly for unknown
    // reasons, so we use 17 steps for a total of 51 LUT entries only.
    static constexpr int kRampSteps = 16;
    static constexpr int kRampMaxStepDurationMs = 15;

    auto makeLedPath = [](const std::string& led, const std::string& op) -> std::string {
        return "/sys/class/leds/" + led + "/" + op;
    };
    auto getScaledDutyPercent = [](int brightness) -> std::string {
        std::string output;
        for (int i = 0; i <= kRampSteps; i++) {
            if (i != 0) {
                output += ",";
            }
            output += std::to_string(i * 512 * brightness / (255 * kRampSteps));
        }
        return output;
    };

    // Disable all blinking before starting
    for (const auto& entry : colorValues) {
        set(makeLedPath(entry.first, "blink"), 0);
    }

    if (onMs > 0 && offMs > 0) {
        int pauseLo, pauseHi, stepDuration, index = 0;
        if (kRampMaxStepDurationMs * kRampSteps > onMs) {
            stepDuration = onMs / kRampSteps;
            pauseHi = 0;
            pauseLo = offMs;
        } else {
            stepDuration = kRampMaxStepDurationMs;
            pauseHi = onMs - kRampSteps * stepDuration;
            pauseLo = offMs - kRampSteps * stepDuration;
        }

        for (const auto& entry : colorValues) {
            set(makeLedPath(entry.first, "lut_flags"), 95);
            set(makeLedPath(entry.first, "start_idx"), index);
            set(makeLedPath(entry.first, "duty_pcts"), getScaledDutyPercent(entry.second));
            set(makeLedPath(entry.first, "pause_lo"), pauseLo);
            set(makeLedPath(entry.first, "pause_hi"), pauseHi);
            set(makeLedPath(entry.first, "ramp_step_ms"), stepDuration);
            index += kRampSteps + 1;
        }

        // Start blinking
        for (const auto& entry : colorValues) {
            set(makeLedPath(entry.first, "blink"), entry.second);
        }
    } else {
        for (const auto& entry : colorValues) {
            set(makeLedPath(entry.first, "brightness"), entry.second);
        }
    }

    LOG(DEBUG) << ::android::base::StringPrintf(
        "handleRgb: mode=%d, color=%08X, onMs=%d, offMs=%d",
        static_cast<std::underlying_type<FlashMode>::type>(stateToUse.flashMode), stateToUse.color,
        onMs, offMs);

    return ndk::ScopedAStatus::ok();

}

ndk::ScopedAStatus Lights::getLights(std::vector<HwLight>* lights) {
    for (auto i = mAvailableLights.begin(); i != mAvailableLights.end(); i++) {
        lights->push_back(*i);
    }
    return ndk::ScopedAStatus::ok();
}

}  // namespace light
}  // namespace hardware
}  // namespace android
}  // namespace aidl
