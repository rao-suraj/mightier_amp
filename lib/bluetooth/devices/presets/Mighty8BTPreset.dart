// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:ui';

import '../NuxDevice.dart';
import '../effects/Processor.dart';
import '../effects/NoiseGate.dart';
import '../effects/mighty_8bt/Amps.dart';
import '../effects/mighty_8bt/Modulation.dart';
import '../effects/mighty_8bt/Delay.dart';
import '../effects/mighty_8bt/Reverb.dart';
import 'Preset.dart';
import 'preset_constants.dart';

class M8BTPreset extends Preset {
  @override
  NuxDevice device;
  @override
  int channel;
  @override
  String channelName;
  @override
  int get qrDataLength => 40;
  @override
  Color get channelColor => PresetConstants.channelColorsPlug[channel];
  final NoiseGate2Param noiseGate = NoiseGate2Param();
  @override
  final List<M8BTAmplifier> amplifierList = <M8BTAmplifier>[];
  final List<Modulation> modulationList = <Modulation>[];
  final List<Delay> delayList = <Delay>[];
  final List<Reverb> reverbList = <Reverb>[];

  bool noiseGateEnabled = true;
  bool modulationEnabled = true;
  bool delayEnabled = true;
  bool reverbEnabled = true;

  int selectedMod = 0;
  int selectedDelay = 0;
  int selectedReverb = 0;

  M8BTPreset(
      {required this.device, required this.channel, required this.channelName})
      : super(channel: channel, channelName: channelName, device: device) {
    //modulation is available everywhere
    modulationList.addAll([Phaser(), Chorus(), Tremolo(), Vibe()]);

    amplifierList.addAll([AmpClean()]);

    delayList.addAll([Delay1(), Delay2(), Delay3(), Delay4()]);

    //reverb is available in all presets
    reverbList
        .addAll([RoomReverb(), HallReverb(), PlateReverb(), SpringReverb()]);
  }

  /// checks if the effect slot can be switched on and off
  @override
  bool slotSwitchable(int index) {
    if (index == 1) return false;
    return true;
  }

  //returns whether the specific slot is on or off
  @override
  bool slotEnabled(int index) {
    switch (index) {
      case 0:
        return noiseGateEnabled;
      case 2:
        return modulationEnabled;
      case 3:
        return delayEnabled;
      case 4:
        return reverbEnabled;
      default:
        return true;
    }
  }

  //turns slot on or off
  @override
  void setSlotEnabled(int index, bool value, bool notifyBT) {
    switch (index) {
      case 0:
        noiseGateEnabled = value;
        break;
      case 2:
        modulationEnabled = value;
        break;
      case 3:
        delayEnabled = value;
        break;
      case 4:
        reverbEnabled = value;
        break;
      default:
        return;
    }

    super.setSlotEnabled(index, value, notifyBT);
  }

  //returns list of effects for given slot
  @override
  List<Processor> getEffectsForSlot(int slot) {
    switch (slot) {
      case 0:
        return [noiseGate];
      case 1:
        return amplifierList;
      case 2:
        return modulationList;
      case 3:
        return delayList;
      case 4:
        return reverbList;
    }
    return <Processor>[];
  }

  //returns which of the effects is selected for a given slot
  @override
  int getSelectedEffectForSlot(int slot) {
    switch (slot) {
      case 0:
        return 0;
      case 1:
        return 0;
      case 2:
        return selectedMod;
      case 3:
        return selectedDelay;
      case 4:
        return selectedReverb;
      default:
        return 0;
    }
  }

  //sets the effect for the given slot
  @override
  void setSelectedEffectForSlot(int slot, int index, bool notifyBT) {
    switch (slot) {
      case 2:
        selectedMod = index;
        break;
      case 3:
        selectedDelay = index;
        break;
      case 4:
        selectedReverb = index;
        break;
    }
    super.setSelectedEffectForSlot(slot, index, notifyBT);
  }

  @override
  Color effectColor(int index) {
    if (index != 1) {
      return device.processorList[index].color;
    } else {
      return channelColor;
    }
  }

  @override
  setFirmwareVersion(int version) {}
}
