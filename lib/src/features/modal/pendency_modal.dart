class CashPendencyModal {
  String? totalCash;
  String? pendencyDate;
  String? reportId;
  String? reportTitle;
  String? srchby;
  String? prevTotalCash;
  String? changeInPer;

  CashPendencyModal({
    this.totalCash,
    this.pendencyDate,
    this.reportId,
    this.reportTitle,
    this.srchby,
    this.prevTotalCash,
    this.changeInPer,
  });

  CashPendencyModal.fromJson(Map<String, dynamic> json) {
    totalCash = json['total_cash'].toString();
    pendencyDate = json['pendency_date'].toString();
    reportId = json['report_id'].toString();
    reportTitle = json['report_title'].toString();
    srchby = json['srchby'].toString();
    prevTotalCash = json['prev_total_cash'].toString();
    changeInPer = json['change_in_per'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_cash'] = this.totalCash;
    data['pendency_date'] = this.pendencyDate;
    data['report_id'] = this.reportId;
    data['report_title'] = this.reportTitle;
    data['srchby'] = this.srchby;
    data['prev_total_cash'] = this.prevTotalCash;
    data['change_in_per'] = this.changeInPer;
    return data;
  }
}
