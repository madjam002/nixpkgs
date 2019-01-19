{ stdenv, fetchurl, makeWrapper, jre
, version ? "1.6" }:

let
  versionMap = {
    "1.5" = {
      flinkVersion = "1.5.5";
      sha256 = "18wqcqi3gyqd40nspih99gq7ylfs20b35f4dcrspffagwkfp2l4z";
    };
    "1.6" = {
      flinkVersion = "1.6.2";
      sha256 = "17fsr6yv1ayr7fw0r4pjlbpkn9ypzjs4brqndzr3gbzwrdc44arw";
    };
  };
in

with versionMap.${version};

stdenv.mkDerivation rec {
  name = "flink-${flinkVersion}";

  src = fetchurl {
    url = "mirror://apache/flink/${name}/${name}-bin-scala_2.11.tgz";
    inherit sha256;
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ jre ];

  installPhase = ''
    rm bin/*.bat

    mkdir -p $out/bin $out/opt/flink
    mv * $out/opt/flink/
    makeWrapper $out/opt/flink/bin/flink $out/bin/flink \
      --prefix PATH : ${jre}/bin

    cat <<EOF >> $out/opt/flink/conf/flink-conf.yaml
    env.java.home: ${jre}"
    env.log.dir: /tmp/flink-logs
    EOF
  '';

  meta = with stdenv.lib; {
    description = "A distributed stream processing framework";
    homepage = https://flink.apache.org;
    downloadPage = https://flink.apache.org/downloads.html;
    license = licenses.asl20;
    platforms = platforms.all;
    maintainers = with maintainers; [ mbode ];
    repositories.git = git://git.apache.org/flink.git;
  };
}
