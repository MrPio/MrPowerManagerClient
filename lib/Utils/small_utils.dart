keepOnlyAlphaNum(String string){
  return string.replaceAll(RegExp('[^A-Za-z0-9]'), '_');
}