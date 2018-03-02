class Reindexer < Formula
  desc "is an fast document-oriented database im-memory database."
  homepage "https://github.com/restream/reindexer"
  url "https://github.com/Restream/reindexer/archive/v1.5.0.zip"
  version "1.5.0"
  sha256 "783eff5f1f0d4dcd972a9b828189fe094697cfa79fc60c12f8e3368ec5fbe8c8"

  head "https://github.com/restream/reindexer.git"

  depends_on "cmake" => :build
  depends_on "leveldb"

  def install

    mkdir "build"
    cd "build" do
      system "cmake", "-DCMAKE_INSTALL_PREFIX=#{prefix}", ".."
      system "make", "-j8"
      system "make", "swagger"
      system "make", "install"
    end

    mkdir "#{var}/reindexer"
    mkdir "#{var}/log/reindexer"

    inreplace "#{buildpath}/build/cpp_src/cmd/reindexer_server/contrib/config.yml" do |s|
      s.gsub! "/var/lib/reindexer", "#{var}/reindexer"
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

  def caveats; <<-EOS
    The configuration file is available at:
      #{etc}/reindexer.conf
    The database itself will store data at:
      #{var}/reindexer/
  EOS
  end
end