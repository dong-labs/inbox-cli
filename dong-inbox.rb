# typed: true
# frozen_string_literal: true

class DongInbox < Formula
  desc "inBox 笔记命令行工具"
  homepage "https://github.com/dong-labs/inBoxProject"
  url "https://github.com/dong-labs/inBoxProject/raw/refs/heads/main/thinkflutter/inbox_cli/archive/dong-inbox-#{version}.tar.gz"
  sha256 :no_check

  version "1.0.0"

  def install
    bin.install "dong-inbox" => "inbox"
  end

  test do
    system "#{bin}/inbox", "--version"
  end
end
