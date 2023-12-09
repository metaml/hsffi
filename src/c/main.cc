#include <iostream>
#include <clang-c/Index.h>

using namespace std;

int main() {
  CXIndex index = clang_createIndex(0, 0);
  CXTranslationUnit unit = clang_parseTranslationUnit(
    index,
    "h.h", nullptr, 0,
    nullptr, 0,
    CXTranslationUnit_None);
  if (unit == nullptr)
  {
    cerr << "unable to parse translation unit" << endl;
    exit(-1);
  }

  clang_disposeTranslationUnit(unit);
  clang_disposeIndex(index);
}
