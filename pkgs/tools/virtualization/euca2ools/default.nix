{ lib, fetchgit, python2Packages }:

let
  inherit (python2Packages) buildPythonApplication boto m2crypto;
in buildPythonApplication {
  pname = "euca2ools";
  version = "2.1.4";

  src = fetchgit {
    url = "https://github.com/eucalyptus/euca2ools.git";
    rev = "19cb7eac34dd7efe3a56e4841b9692c03458bf3b";
    sha256 = "0grsgn5gbvk1hlfa8qx7ppz7iyfyi2pdhxy8njr8lm60w4amfiyq";
  };

  propagatedBuildInputs = [ boto m2crypto ];

  meta = {
    homepage = "https://github.com/eucalyptus/euca2ools";
    description = "Tools for interacting with Amazon EC2/S3-compatible cloud computing services";
    maintainers = [ lib.maintainers.eelco ];
    platforms = lib.platforms.linux;
  };
}
