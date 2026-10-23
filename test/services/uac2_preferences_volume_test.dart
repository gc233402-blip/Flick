import 'package:flutter_test/flutter_test.dart';
import 'package:flick/services/uac2_preferences_service.dart';
import 'package:flick/services/uac2_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const deviceA = Uac2DeviceInfo(
  vendorId: 0x1234,
  productId: 0x5678,
  productName: 'Test DAC',
  manufacturer: 'Test Audio',
  serial: 'SERIAL-A',
  deviceName: '/dev/bus/usb/001/002',
);

const deviceB = Uac2DeviceInfo(
  vendorId: 0x1234,
  productId: 0x5678,
  productName: 'Test DAC',
  manufacturer: 'Test Audio',
  serial: 'SERIAL-B',
  deviceName: '/dev/bus/usb/001/003',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to 40 percent for a DAC with no saved level', () async {
    final prefs = Uac2PreferencesService();

    expect(
      await prefs.getUsbVolumeForDevice(deviceA),
      Uac2PreferencesService.defaultUsbDacVolume,
    );
  });

  test('round-trips per-device levels including zero and one', () async {
    final prefs = Uac2PreferencesService();

    await prefs.setUsbVolumeForDevice(deviceA, 0.0);
    await prefs.setUsbVolumeForDevice(deviceB, 1.0);

    expect(await prefs.getUsbVolumeForDevice(deviceA), 0.0);
    expect(await prefs.getUsbVolumeForDevice(deviceB), 1.0);

    await prefs.setUsbVolumeForDevice(deviceA, 0.27);
    expect(await prefs.getUsbVolumeForDevice(deviceA), closeTo(0.27, 1e-9));
    expect(await prefs.getUsbVolumeForDevice(deviceB), 1.0);
  });

  test('path-like serials fall back to the device model', () {
    const androidRouteDevice = Uac2DeviceInfo(
      vendorId: 0x1234,
      productId: 0x5678,
      productName: 'Test DAC',
      manufacturer: 'Test Audio',
      serial: '/dev/bus/usb/001/002',
      deviceName: '/dev/bus/usb/001/002',
    );
    const sameModelWithoutSerial = Uac2DeviceInfo(
      vendorId: 0x1234,
      productId: 0x5678,
      productName: 'Test DAC',
      manufacturer: 'Test Audio',
    );

    expect(
      Uac2PreferencesService.usbDeviceVolumeKey(androidRouteDevice),
      Uac2PreferencesService.usbDeviceVolumeKey(sameModelWithoutSerial),
    );
  });

  test(
    'migrates the legacy global level to only the first DAC',
    () async {
      SharedPreferences.setMockInitialValues({
        'uac2_usb_software_volume': 0.33,
      });
      final prefs = Uac2PreferencesService();

      expect(await prefs.getUsbVolumeForDevice(deviceA), closeTo(0.33, 1e-9));
      expect(
        await prefs.getUsbVolumeForDevice(deviceB),
        Uac2PreferencesService.defaultUsbDacVolume,
      );

      await prefs.setUsbVolumeForDevice(deviceA, 0.55);
      expect(await prefs.getUsbVolumeForDevice(deviceA), closeTo(0.55, 1e-9));
      // The legacy value belonged to the old single global slot, not to some
      // other DAC the user has never connected.
      expect(
        await prefs.getUsbVolumeForDevice(deviceB),
        Uac2PreferencesService.defaultUsbDacVolume,
      );
    },
  );

  test('remembered levels survive a new preferences service', () async {
    await Uac2PreferencesService().setUsbVolumeForDevice(deviceA, 0.27);

    expect(
      await Uac2PreferencesService().getUsbVolumeForDevice(deviceA),
      closeTo(0.27, 1e-9),
    );
  });

  test('ignores non-finite levels instead of saving full volume', () async {
    final prefs = Uac2PreferencesService();
    await prefs.setUsbVolumeForDevice(deviceA, 0.27);

    await prefs.setUsbVolumeForDevice(deviceA, double.nan);
    await prefs.setUsbVolumeForDevice(deviceA, double.infinity);

    expect(await prefs.getUsbVolumeForDevice(deviceA), closeTo(0.27, 1e-9));
  });

  test('invalid persisted levels use the first-use default', () async {
    final key = Uac2PreferencesService.usbDeviceVolumeKey(deviceA);
    SharedPreferences.setMockInitialValues({
      'uac2_usb_device_volumes': '{"$key":1e999}',
    });

    expect(
      await Uac2PreferencesService().getUsbVolumeForDevice(deviceA),
      Uac2PreferencesService.defaultUsbDacVolume,
    );
  });

  test('clearing preferences removes remembered per-device levels', () async {
    final prefs = Uac2PreferencesService();
    await prefs.setUsbVolumeForDevice(deviceA, 0.22);

    await prefs.clearAllPreferences();

    expect(
      await prefs.getUsbVolumeForDevice(deviceA),
      Uac2PreferencesService.defaultUsbDacVolume,
    );
  });
}
