class BaseResponse {
  bool error;
  String message;

  BaseResponse({required this.error, required this.message});

  factory BaseResponse.fromJson(Map<String, dynamic> json) =>
      BaseResponse(error: json["error"], message: json["message"]);

  Map<String, dynamic> toJson() => {"error": error, "message": message};
}
