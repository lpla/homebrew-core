class Dovecot < Formula
  desc "IMAP/POP3 server"
  homepage "https://dovecot.org/"
  url "https://dovecot.org/releases/2.3/dovecot-2.3.16.tar.gz"
  sha256 "03a71d53055bd9ec528d55e07afaf15c09dec9856cba734904bfd05acbc6cf12"
  license all_of: ["BSD-3-Clause", "LGPL-2.1-or-later", "MIT", "Unicode-DFS-2016", :public_domain]

  livecheck do
    url "https://dovecot.org/download"
    regex(/href=.*?dovecot[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 arm64_big_sur: "b9f839dba9468f7eae88b0dd3fc82b5b874090e36a6acda2bb4213aec9643c0f"
    sha256 big_sur:       "e2e2f8de6497655aaa4f3500e7daf815039ae7d5f4ab665a24479a93f0268f4f"
    sha256 catalina:      "5e8f0e607c4ae4db5333adcba429c19c4292ad72512ee05a574ec412df1a066a"
    sha256 mojave:        "23d56aa20b37f916b2942a2183529b9520072593439bb132c21dd82c91ca4d11"
    sha256 x86_64_linux:  "7c3e4c41a5904e96cff0f9201c9bc83fa139f873832d6f52e68f15a03d4f0a97"
  end

  depends_on "openssl@1.1"

  uses_from_macos "bzip2"
  uses_from_macos "sqlite"

  on_linux do
    depends_on "linux-pam"
  end

  resource "pigeonhole" do
    url "https://pigeonhole.dovecot.org/releases/2.3/dovecot-2.3-pigeonhole-0.5.16.tar.gz"
    sha256 "5ca36780e23b99e6206440f1b3fe3c6598eda5b699b99cebb15d418ba3c6e938"
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --libexecdir=#{libexec}
      --sysconfdir=#{etc}
      --localstatedir=#{var}
      --with-bzlib
      --with-pam
      --with-sqlite
      --with-ssl=openssl
      --with-zlib
    ]

    system "./configure", *args
    system "make", "install"

    resource("pigeonhole").stage do
      args = %W[
        --disable-dependency-tracking
        --with-dovecot=#{lib}/dovecot
        --prefix=#{prefix}
      ]

      system "./configure", *args
      system "make"
      system "make", "install"
    end
  end

  def caveats
    <<~EOS
      For Dovecot to work, you may need to create a dovecot user
      and group depending on your configuration file options.
    EOS
  end

  plist_options startup: true

  service do
    run [opt_sbin/"dovecot", "-F"]
    environment_variables PATH: std_service_path_env
    error_log_path var/"log/dovecot/dovecot.log"
    log_path var/"log/dovecot/dovecot.log"
  end

  test do
    assert_match version.to_s, shell_output("#{sbin}/dovecot --version")
  end
end
