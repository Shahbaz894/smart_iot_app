class FaultHelper {
  static String getFaultDescription(int code) {
    const faults = {
      0: "No Fault",
      1: "Output phase fault",
      2: "Output abnormality",
      3: "Output phase imbalance",
      4: "Acceleration Over current",
      5: "Deceleration Over current",
      6: "Constant Speed Over current",
      7: "Acceleration Over voltage",
      8: "Deceleration Over voltage",
      9: "Constant Over voltage",
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