self: super:
with self; {
  confusable_homoglyphs = callPackage ./confusable_homoglyphs.nix {};
  django-registration = callPackage ./django-registration.nix {};
  django-sass-processor = callPackage ./django-sass-processor.nix {};
  mozilla-django-oidc = callPackage ./mozilla-django-oidc.nix {};
  waybackpy = callPackage ./waybackpy.nix {};
}
