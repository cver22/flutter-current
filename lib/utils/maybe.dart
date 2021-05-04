class Maybe<T> {
  final T? _value;
  Maybe._(this._value);
  factory Maybe.none() {
    return Maybe._(null);
  }
  factory Maybe.some(T value) {
    if (value == null) {
      throw ArgumentError('Value can’t be null');
    }
    return Maybe._(value);
  }
  factory Maybe.maybe(T? value) {
    return Maybe._(value);
  }
  T get value {
    if(_value != null) {
      return _value!;
    }
    else {
      throw Exception('Value does not exists');
    }
  }
  Maybe<R> map<R>(R mapper(T t)) {
    return _value != null ? Maybe.some(mapper(_value!)) : Maybe.none();
  }
  T orElse(T defVal) {
    return _value ?? defVal;
  }
  Maybe<R> flatMap<R>(Maybe<R> mapper(T t)) {
    return _value != null ? mapper(_value!) : Maybe.none();
  }
  bool get isSome => _value != null;
  bool get isNone => _value == null;
  @override
  int get hashCode {
    if(_value != null) {
      return _value!.hashCode;
    }
    else {
      throw Exception('Value does not exists');
    }
  }
  @override
  String toString() {
    return isSome ? 'Some: $_value' : 'None';
  }
  @override
  bool operator == (Object other) {
    if(other is Maybe<T>) {
      if(this.isSome) {
        return other.isSome && this._value == other._value;
      }
      else {
        return other.isNone;
      }
    }
    else if (other is T) {
      return this.isSome && this._value == other;
    }
    else {
      return false;
    }
  }
}