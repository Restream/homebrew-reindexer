class Reindexer < Formula
  env :std
  desc "is a fast document-oriented in-memory database."
  homepage "https://github.com/restream/reindexer"
  url "https://github.com/Restream/reindexer/archive/v5.4.0.zip"
  version "5.4.0"
  sha256 "519ea6deadc66dd7fb6f88ced4d0ed9e4284e58e3d52e318784c3df74ecd9f96"

  head "https://github.com/restream/reindexer.git"

  depends_on "cmake" => :build
  depends_on "leveldb"
  depends_on "libomp"
  depends_on "openblas"

  service do
    name macos: "#{plist_name}"
  end

  def install

    mkdir "build"
    cd "build" do
      system "cmake", "-DCMAKE_INSTALL_PREFIX=#{prefix}", ".."
      system "make", "-j8", "reindexer_server", "reindexer_tool", "install"
    end

    mkdir "#{var}/reindexer"
    mkdir "#{var}/log/reindexer"

    inreplace "#{buildpath}/build/cpp_src/cmd/reindexer_server/contrib/config.yml" do |s|
      s.gsub! "/var/lib/reindexer", "#{var}/reindexer"
      s.gsub! "/var/log/reindexer", "#{var}/log/reindexer"
      s.gsub! "user:", "# user:"
    end

    # Copy configuration files
    etc.install "#{buildpath}/build/cpp_src/cmd/reindexer_server/contrib/config.yml" => "reindexer.conf"
  end

  def plist; <<-EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/reindexer_server</string>
            <string>--config</string>
            <string>#{etc}/reindexer.conf</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/reindexer/reindexer.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/reindexer/reindexer.log</string>
        </dict>
    </plist>
    EOS
  end
  #bottle do
    #root_url "http://repo.reindexer.org/brew-bottles"
    #sha256 cellar: :any, mojave: "bf2988d1c728640b77e48d05c8187a733ce311c9571703254f5bd4ed46fb3158"
  #end
  def caveats; <<-EOS
    The configuration file is available at:
      #{etc}/reindexer.conf
    The database itself will store data at:
      #{var}/reindexer/
  EOS
  end
end
