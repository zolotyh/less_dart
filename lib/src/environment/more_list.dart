part of environment.less;

///
/// List functions
///
class MoreList {


  /// Add [element] if not found
  static addUnique(List to, element) {
    if (!to.contains(element)) to.add(element);
  }

  ///
  /// Add all elements of [from] to [to] after transformation with
  /// function: map(element) => other element
  ///
  static List addAllUnique(List to, List from, {Function map}) {
    if (from == null) return to;
    from.forEach((item){
      if (map != null) item = map(item);
      addUnique(to, item);
    });
    return to;
  }

}