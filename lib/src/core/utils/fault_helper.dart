class FaultHelper {
  static String getFaultDescription(int code) {
    const faults = {
      0: "No Fault",
      1: "Output phase fault",
      2: "Output abnormality",
      3: "Output phase imbalance",
      4: "Acceleration Overcurrent",
      5: "Deceleration Overcurrent",
      6: "Constant Speed Overcurrent",
      7: "Acceleration Overvoltage",
      8: "Deceleration Overvoltage",
      9: "Constant Overvoltage",
      10: "Under Voltage",
      11: "Motor Overload",
      12: "Drive Overload",
      13: "Internal communication fault",
      14: "Output protection triggered",
      15: "Drive Overheat",
      16: "Motor Overheat",
      17: "External Fault",
      18: "Communication Error",
    };

    return faults[code] ?? "Unknown Fault";
  }
}