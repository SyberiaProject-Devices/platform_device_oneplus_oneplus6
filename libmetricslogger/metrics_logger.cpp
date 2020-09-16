/*
 * Copyright (C) 2017 The Android Open Source Project
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

#include "metrics_logger.h"
#include <cstdlib>

using namespace android;

namespace android {
namespace metricslogger {

void LogHistogram(const std::string& event, int32_t data) {
}

void LogCounter(const std::string& name, int32_t val) {
}

void LogMultiAction(int32_t category, int32_t field, const std::string& value) {
}

void ComplexEventLogger::SetPackageName(const std::string& package_name) {
}

void ComplexEventLogger::AddTaggedData(int tag, int32_t value) {
}

void ComplexEventLogger::AddTaggedData(int tag, const std::string& value) {
}

void ComplexEventLogger::AddTaggedData(int tag, int64_t value) {
}

void ComplexEventLogger::AddTaggedData(int tag, float value) {
}

void ComplexEventLogger::Record() {
}

}  // namespace metricslogger
}  // namespace android
