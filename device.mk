#
# Copyright (C) 2018 The LineageOS Project
# Copyright (C) 2019 Syberia Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/product_launched_with_o_mr1.mk)

# Get non-open-source specific aspects
$(call inherit-product, vendor/oneplus/sdm845-common/sdm845-common-vendor.mk)

# Overlays
PRODUCT_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay \

PRODUCT_PACKAGES += \
    NoCutoutOverlay

# Device uses high-density artwork where available
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxhdpi

# Properties
-include $(LOCAL_PATH)/system_prop.mk

PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE := true

# A/B
AB_OTA_UPDATER := true

AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    system \
    vbmeta

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

PRODUCT_PACKAGES += \
    otapreopt_script

# ANT+
PRODUCT_PACKAGES += \
    AntHalService

# Audio
PRODUCT_PACKAGES += \
    audio.a2dp.default

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/audio/audio_policy_configuration.xml:system/etc/audio_policy_configuration.xml \
    $(LOCAL_PATH)/configs/msm_irqbalance.conf:system/etc/msm_irqbalance.conf

# Boot control
PRODUCT_PACKAGES_DEBUG += \
    android.hardware.boot@1.0-impl.recovery \
    bootctl

# Common init scripts
PRODUCT_PACKAGES += \
    init.qcom.rc \
    init.performance.rc \
    init.recovery.qcom.rc

# Dex
PRODUCT_DEXPREOPT_SPEED_APPS += \
    SystemUI

# Display
PRODUCT_PACKAGES += \
    libvulkan \
    libdisplayconfig \
    libqdMetaData.system \
    vendor.display.config@1.7


# Hostapd
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/hostapd/hostapd.accept:system/etc/hostapd/hostapd.accept \
    $(LOCAL_PATH)/configs/hostapd/hostapd.deny:system/etc/hostapd/hostapd.deny \
    $(LOCAL_PATH)/configs/hostapd/hostapd_default.conf:system/etc/hostapd/hostapd_default.conf

PRODUCT_PACKAGES += \
    move_wifi_data.sh

# HotwordEnrollement app permissions
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/privapp-permissions-hotword.xml:system/etc/permissions/privapp-permissions-hotword.xml

# IMS
PRODUCT_PACKAGES += \
    android.hidl.base@1.0

# Input
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/idc/gf_input.idc:system/usr/idc/gf_input.idc \
    $(LOCAL_PATH)/keylayout/gf_input.kl:system/usr/keylayout/gf_input.kl

# Lights
PRODUCT_PACKAGES += \
    android.hardware.light@2.0-service.oneplus_sdm845

# LiveDisplay
PRODUCT_PACKAGES += \
    lineage.livedisplay@2.0-service.oneplus_sdm845

# Media
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/media_profiles_vendor.xml:system/etc/media_profiles_vendor.xml

# Net
PRODUCT_PACKAGES += \
    netutils-wrapper-1.0

# NFC
PRODUCT_PACKAGES += \
    android.hardware.nfc@1.0:64 \
    android.hardware.nfc@1.1:64 \
    android.hardware.secure_element@1.0:64 \
    com.android.nfc_extras \
    Tag \
    vendor.nxp.nxpese@1.0:64 \
    vendor.nxp.nxpnfc@1.0:64

# OnePlus Camera HIDL
PRODUCT_PACKAGES += \
    vendor.oneplus.camera.CameraHIDL@1.0 \
    vendor.oneplus.camera.CameraHIDL@1.0-adapter-helper \
    vendor.oneplus.camera.CameraHIDL-V1.0-java

# Power
PRODUCT_PACKAGES += \
    power.qcom:64

# Prebuilts
PRODUCT_PACKAGES += \
    OnePlusCamera \
    OnePlusGallery \
    OnePlusCameraService

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/prebuilts/etc/permissions/privapp-permissions-oem.xml:system/etc/permissions/privapp-permissions-oem.xml

# Device Parts
PRODUCT_PACKAGES += \
    DeviceParts

# Telephony
PRODUCT_PACKAGES += \
    telephony-ext

PRODUCT_BOOT_JARS += \
    telephony-ext

# Update engine
PRODUCT_PACKAGES += \
    bootctrl.sdm845.recovery \
    update_engine \
    update_engine_sideload \
    update_verifier

PRODUCT_PACKAGES_DEBUG += \
    update_engine_client

#QTI performance
PRODUCT_BOOT_JARS += \
    QPerformance \
    UxPerformance

# WiFi Display
PRODUCT_PACKAGES += \
    libnl

PRODUCT_BOOT_JARS += \
    WfdCommon
    
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/privapp-permissions-wfd.xml:system/etc/permissions/privapp-permissions-wfd.xml

# Updater
PRODUCT_PACKAGES += \
    Updater