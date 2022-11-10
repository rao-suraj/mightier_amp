// (c) 2020-2021 Dian Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxMightyPlugPro.dart';
import 'package:mighty_plug_manager/bluetooth/devices/communication/plugProCommunication.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/plug_pro/EmptyEffects.dart';

import '../../NuxDeviceControl.dart';
import '../NuxConstants.dart';
import '../NuxDevice.dart';
import '../effects/Processor.dart';
import '../effects/NoiseGate.dart';
import '../effects/plug_pro/Compressor.dart';
import '../effects/plug_pro/EFX.dart';
import '../effects/plug_pro/Amps.dart';
import '../effects/plug_pro/Cabinet.dart';
import '../effects/plug_pro/Modulation.dart';
import '../effects/plug_pro/Delay.dart';
import '../effects/plug_pro/Reverb.dart';
import '../effects/plug_pro/EQ.dart';
import 'Preset.dart';

class PlugProPreset extends Preset {
  static const List<Color> channelColors = [
    Color.fromARGB(255, 0, 255, 0),
    Color.fromARGB(255, 240, 160, 10),
    Color.fromARGB(255, 220, 0, 0),
    Colors.blue,
    Color.fromARGB(255, 130, 225, 255),
    Color.fromARGB(255, 231, 120, 215),
    Color(0xFFE1BEE7),
  ];
  @override
  NuxDevice device;
  @override
  int channel;
  @override
  String channelName;
  @override
  Color get channelColor => PlugProPreset.channelColors[channel];
  @override
  List<Color> get channelColorsList => PlugProPreset.channelColors;

  @override
  int get qrDataLength => 113;

  final WahDummyPro wahDummy = WahDummyPro();
  final NoiseGatePro noiseGate = NoiseGatePro();

  final List<Compressor> compressorList = <Compressor>[];
  final List<EFX> efxList = <EFX>[];
  final List<CabinetPro> cabinetList = <CabinetPro>[];
  final List<Modulation> modulationList = <Modulation>[];
  final List<Reverb> reverbList = <Reverb>[];
  @override
  final List<Amplifier> amplifierList = <Amplifier>[];
  final List<Delay> delayList = <Delay>[];
  final List<EQ> eqList = <EQ>[];

  //presets stored in nux indexing (unused Wah is 0)
  List<int> processorAtSlot = [];

  bool wahEnabled = true;
  bool noiseGateEnabled = true;
  bool compressorEnabled = true;
  bool efxEnabled = true;
  bool ampEnabled = true;
  bool irEnabled = true;
  bool modulationEnabled = true;
  bool eqEnabled = true;
  bool delayEnabled = true;
  bool reverbEnabled = true;

  int selectedComp = 0;
  int selectedEfx = 0;
  int selectedAmp = 0;
  int selectedCabinet = 0;
  int selectedMod = 0;
  int selectedEQ = 0;
  int selectedDelay = 0;
  int selectedReverb = 0;

  PlugProVersion version = PlugProVersion.PlugPro1;

  PlugProPreset(
      {required this.device, required this.channel, required this.channelName})
      : super(channel: channel, channelName: channelName, device: device) {
    compressorList.addAll([RoseComp(), KComp(), StudioComp()]);

    modulationList.addAll([
      ModCE1(),
      ModCE2(),
      STChorus(),
      Vibrato(),
      Detune(),
      Flanger(),
      Phase90(),
      Phase100(),
      SCF(),
      Vibe(),
      Tremolo(),
      Rotary(),
      SCH1(),
    ]);

    efxList.addAll([
      DistortionPlus(),
      RCBoost(),
      ACBoost(),
      DistOne(),
      TSDrive(),
      BluesDrive(),
      MorningDrive(),
      EatDist(),
      RedDirt(),
      Crunch(),
      MuffFuzz(),
      Katana(),
      STSinger(),
    ]);

    amplifierList.addAll([
      if (kDebugMode) Unknown0(),
      JazzClean(),
      DeluxeRvb(),
      BassMate(),
      Tweedy(),
      if (kDebugMode) Unknown5(),
      HiWire(),
      CaliCrunch(),
      if (kDebugMode) Unknown8(),
      ClassA30(),
      Plexi100(),
      Plexi45(),
      Brit800(),
      Pl1987x50(),
      Slo100(),
      FiremanHBE(),
      DualRect(),
      DIEVH4(),
      if (kDebugMode) Unknown18(),
      if (kDebugMode) Unknown19(),
      MrZ38(),
      SuperRvb(),
      if (kDebugMode) Unknown22(),
      if (kDebugMode) Unknown23(),
      if (kDebugMode) Unknown24(),
      if (kDebugMode) Unknown25(),
      AGL(),
      MLD(),
      OptimaAir(),
      Stageman(),
      if (kDebugMode) Unknown30()
    ]);

    eqList.addAll([EQSixBand(), EQTenBand()]);

    cabinetList.addAll([
      JZ120Pro(),
      DR112Pro(),
      TR212Pro(),
      HIWIRE412(),
      CALI112(),
      A112(),
      GB412Pro(),
      M1960AX(),
      M1960AV(),
      M1960TV(),
      SLO412(),
      FIREMAN412(),
      RECT412(),
      DIE412(),
      MATCH212(),
      UBER412(),
      BS410(),
      A212Pro(),
      M1960AHW(),
      M1936(),
      BUDDA112(),
      Z212(),
      SUPERVERB410(),
      VIBROKING310(),
      AGLDB810(),
      AMPSV212(),
      AMPSV410(),
      AMPSV810(),
      BASSGUY410(),
      EDEN410(),
      MKB410(),
      GHBIRDPro(),
      GJ15Pro(),
      MD45Pro(),
    ]);

    //add the user cabs
    for (int i = 0; i < PlugProCommunication.customIRsCount; i++) {
      var userCab = UserCab();
      userCab.setNuxIndex(i + PlugProCommunication.customIRStart + 1);
      if (i == 0) {
        userCab.isSeparator = true;
        userCab.category = "User IRs";
      }
      cabinetList.add(userCab);
    }

    delayList.addAll(
        [AnalogDelay(), DigitalDelay(), ModDelay(), TapeEcho(), PanDelay()]);

    //reverb is available in all presets
    reverbList.addAll([
      RoomReverb(),
      HallReverb(),
      PlateReverb(),
      SpringReverb(),
      ShimmerReverb()
    ]);

    for (int i = 0; i < PresetDataIndexPlugPro.defaultEffects.length; i++) {
      processorAtSlot.add(PresetDataIndexPlugPro.defaultEffects[i]);
    }
  }

  /// checks if the effect slot can be switched on and off
  @override
  bool slotSwitchable(int index) {
    return true;
  }

  //returns whether the specific slot is on or off
  @override
  bool slotEnabled(int index) {
    var proc = getProcessorAtSlot(index);
    return _slotEnabledNuxIndex(proc);
  }

  bool _slotEnabledNuxIndex(int proc) {
    switch (proc) {
      case PresetDataIndexPlugPro.Head_iWAH:
        return wahEnabled;
      case PresetDataIndexPlugPro.Head_iNG:
        return noiseGateEnabled;
      case PresetDataIndexPlugPro.Head_iCMP:
        return compressorEnabled;
      case PresetDataIndexPlugPro.Head_iEFX:
        return efxEnabled;
      case PresetDataIndexPlugPro.Head_iAMP:
        return ampEnabled;
      case PresetDataIndexPlugPro.Head_iCAB:
        return irEnabled;
      case PresetDataIndexPlugPro.Head_iMOD:
        return modulationEnabled;
      case PresetDataIndexPlugPro.Head_iEQ:
        return eqEnabled;
      case PresetDataIndexPlugPro.Head_iDLY:
        return delayEnabled;
      case PresetDataIndexPlugPro.Head_iRVB:
        return reverbEnabled;
      default:
        return false;
    }
  }

  //turns slot on or off
  @override
  void setSlotEnabled(int index, bool value, bool notifyBT) {
    var proc = getProcessorAtSlot(index);
    _setNuxSlotEnabled(proc, value);
    super.setSlotEnabled(index, value, notifyBT);
  }

  void _setNuxSlotEnabled(int index, bool value) {
    switch (index) {
      case PresetDataIndexPlugPro.Head_iWAH:
        wahEnabled = value;
        break;
      case PresetDataIndexPlugPro.Head_iNG:
        noiseGateEnabled = value;
        break;
      case PresetDataIndexPlugPro.Head_iCMP:
        compressorEnabled = value;
        break;
      case PresetDataIndexPlugPro.Head_iEFX:
        efxEnabled = value;
        break;
      case PresetDataIndexPlugPro.Head_iAMP:
        ampEnabled = value;
        break;
      case PresetDataIndexPlugPro.Head_iCAB:
        irEnabled = value;
        break;
      case PresetDataIndexPlugPro.Head_iMOD:
        modulationEnabled = value;
        break;
      case PresetDataIndexPlugPro.Head_iEQ:
        eqEnabled = value;
        break;
      case PresetDataIndexPlugPro.Head_iDLY:
        delayEnabled = value;
        break;
      case PresetDataIndexPlugPro.Head_iRVB:
        reverbEnabled = value;
        break;
      default:
        return;
    }
  }

  @override
  int getProcessorAtSlot(int slot) {
    return processorAtSlot[slot];
  }

  int? getSlotIndexFromNuxIndex(int nuxIndex) {
    for (int i = 0; i < processorAtSlot.length; i++)
      if (processorAtSlot[i] == nuxIndex) return i;
    return null;
  }

  @override
  void setProcessorAtSlot(int slot, int processorId) {
    processorAtSlot[slot] = processorId;
  }

  @override
  void swapProcessorSlots(int from, int to, notifyBT) {
    var fxFrom = processorAtSlot[from];

    //shift all after 'from' one position to the left
    for (int i = from; i < device.processorList.length - 1; i++) {
      processorAtSlot[i] = processorAtSlot[i + 1];
    }

    //shift all at and after 'to' one position to the right to make room
    for (int i = device.processorList.length - 1; i > to; i--) {
      processorAtSlot[i] = processorAtSlot[i - 1];
    }

    //place the moved one
    processorAtSlot[to] = fxFrom;

    super.swapProcessorSlots(from, to, notifyBT);
  }

  //returns list of effects for given slot
  @override
  List<Processor> getEffectsForSlot(int slot) {
    var proc = getProcessorAtSlot(slot);
    return _getEffectsForNuxSlot(proc);
  }

  List<Processor> _getEffectsForNuxSlot(int slot) {
    switch (slot) {
      case PresetDataIndexPlugPro.Head_iWAH:
        return [wahDummy];
      case PresetDataIndexPlugPro.Head_iNG:
        return [noiseGate];
      case PresetDataIndexPlugPro.Head_iCMP:
        return compressorList;
      case PresetDataIndexPlugPro.Head_iEFX:
        return efxList;
      case PresetDataIndexPlugPro.Head_iAMP:
        return amplifierList;
      case PresetDataIndexPlugPro.Head_iCAB:
        return cabinetList;
      case PresetDataIndexPlugPro.Head_iMOD:
        return modulationList;
      case PresetDataIndexPlugPro.Head_iEQ:
        return eqList;
      case PresetDataIndexPlugPro.Head_iDLY:
        return delayList;
      case PresetDataIndexPlugPro.Head_iRVB:
        return reverbList;
    }
    return <Processor>[];
  }

  //returns which of the effects is selected for a given slot
  @override
  int getSelectedEffectForSlot(int slot) {
    var proc = getProcessorAtSlot(slot);
    return _getSelectedEffectForNuxSlot(proc);
  }

  int _getSelectedEffectForNuxSlot(int slot) {
    switch (slot) {
      case PresetDataIndexPlugPro.Head_iCMP:
        return selectedComp;
      case PresetDataIndexPlugPro.Head_iEFX:
        return selectedEfx;
      case PresetDataIndexPlugPro.Head_iAMP:
        return selectedAmp;
      case PresetDataIndexPlugPro.Head_iCAB:
        return selectedCabinet;
      case PresetDataIndexPlugPro.Head_iMOD:
        return selectedMod;
      case PresetDataIndexPlugPro.Head_iEQ:
        return selectedEQ;
      case PresetDataIndexPlugPro.Head_iDLY:
        return selectedDelay;
      case PresetDataIndexPlugPro.Head_iRVB:
        return selectedReverb;
      default:
        return 0;
    }
  }

  //sets the effect for the given slot
  @override
  void setSelectedEffectForSlot(int slot, int index, bool notifyBT) {
    var proc = getProcessorAtSlot(slot);
    _setSelectedEffectForNuxSlot(proc, index);

    super.setSelectedEffectForSlot(slot, index, notifyBT);
  }

  @override
  int getEffectArrayIndexFromNuxIndex(int nuxSlot, int nuxIndex) {
    List<Processor> list = [];
    switch (nuxSlot) {
      case PresetDataIndexPlugPro.Head_iWAH:
        return 0;
      case PresetDataIndexPlugPro.Head_iNG:
        return 0;
      case PresetDataIndexPlugPro.Head_iCMP:
        list = compressorList;
        break;
      case PresetDataIndexPlugPro.Head_iEFX:
        list = efxList;
        break;
      case PresetDataIndexPlugPro.Head_iAMP:
        list = amplifierList;
        break;
      case PresetDataIndexPlugPro.Head_iCAB:
        list = cabinetList;
        break;
      case PresetDataIndexPlugPro.Head_iMOD:
        list = modulationList;
        break;
      case PresetDataIndexPlugPro.Head_iEQ:
        list = eqList;
        break;
      case PresetDataIndexPlugPro.Head_iDLY:
        list = delayList;
        break;
      case PresetDataIndexPlugPro.Head_iRVB:
        list = reverbList;
        break;
    }
    for (int i = 0; i < list.length; i++) {
      if (list[i].nuxIndex == nuxIndex) return i;
    }

    return 0;
  }

  void _setSelectedEffectForNuxSlot(int slot, int index) {
    switch (slot) {
      case PresetDataIndexPlugPro.Head_iCMP:
        selectedComp = index;
        break;
      case PresetDataIndexPlugPro.Head_iEFX:
        selectedEfx = index;
        break;
      case PresetDataIndexPlugPro.Head_iAMP:
        selectedAmp = index;
        break;
      case PresetDataIndexPlugPro.Head_iCAB:
        selectedCabinet = index;
        break;
      case PresetDataIndexPlugPro.Head_iMOD:
        selectedMod = index;
        break;
      case PresetDataIndexPlugPro.Head_iEQ:
        selectedEQ = index;
        break;
      case PresetDataIndexPlugPro.Head_iDLY:
        selectedDelay = index;
        break;
      case PresetDataIndexPlugPro.Head_iRVB:
        selectedReverb = index;
        break;
    }
  }

  @override
  Color effectColor(int index) {
    index = getProcessorAtSlot(index);
    return device.processorListNuxIndex(index)?.color ?? Colors.grey;
  }

  @override
  setFirmwareVersion(int version) {
    this.version = PlugProVersion.values[version];
  }

  @override
  void setupPresetFromNuxDataArray(List<int> nuxData) {
    if (nuxData.length < 10) return;

    var loadedPreset = hex.encode(nuxData);

    NuxDeviceControl.instance().diagData.lastNuxPreset = loadedPreset;
    NuxDeviceControl.instance().updateDiagnosticsData(nuxPreset: loadedPreset);

    for (int i = 0; i < PresetDataIndexPlugPro.effectTypesIndex.length; i++) {
      int nuxSlot = PresetDataIndexPlugPro.effectTypesIndex[i];
      //set proper effect
      int effectParam = nuxData[nuxSlot];
      int effectIndex = effectParam & 0x3f;
      bool effectOn = (effectParam & 0x40) == 0;

      effectIndex = getEffectArrayIndexFromNuxIndex(nuxSlot, effectIndex);

      _setSelectedEffectForNuxSlot(nuxSlot, effectIndex);

      //enable/disable effect
      _setNuxSlotEnabled(nuxSlot, effectOn);

      _getEffectsForNuxSlot(nuxSlot)[effectIndex].setupFromNuxPayload(nuxData);
    }

    //effects chain arrangement
    int start = PresetDataIndexPlugPro.LINK1;

    //fix for QR
    for (int i = 0; i < 3; i++) {
      if (!PresetDataIndexPlugPro.effectTypesIndex.contains(nuxData[start])) {
        start++;
      }
    }

    for (int i = 0; i < device.effectsChainLength; i++) {
      processorAtSlot[i] = nuxData[start + i];
    }
  }

  @override
  List<int> createNuxDataFromPreset() {
    List<int> data = List.filled(qrDataLength, 0);

    List<int> qrData = [];
    qrData.add(device.deviceQRId);
    qrData.add(device.deviceQRVersion);

    for (int i = 0; i < PresetDataIndexPlugPro.effectTypesIndex.length; i++) {
      var slot = PresetDataIndexPlugPro.effectTypesIndex[i];
      _getEffectsForNuxSlot(slot)[_getSelectedEffectForNuxSlot(slot)]
          .getNuxPayload(data, _slotEnabledNuxIndex(slot));
    }

    //fx chain order
    int start = PresetDataIndexPlugPro.LINK1;

    //store fx chain
    for (int i = 0; i < device.effectsChainLength; i++) {
      data[start + i] = processorAtSlot[i];
    }

    qrData.addAll(data);
    return qrData;
  }
}
