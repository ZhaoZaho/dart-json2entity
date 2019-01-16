class Model {
  num result;
  String msg;

  Model(this.result, this.msg);
}

class Model2 {
  num result;
  String msg;

  Model2({this.result, this.msg});
}

class BaseModel<T> extends Model {
  T data;

  BaseModel(num result, String msg) : super(result, msg);
}

class LoginData {
  String token;
  String id;
}

class LoginModel<LoginData> {
  
}