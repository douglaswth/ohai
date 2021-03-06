#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper.rb')
require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper.rb') 

describe Ohai::System, "Linux plugin platform" do
  before(:each) do
    @plugin = get_plugin("linux/platform")
    @plugin.extend(SimpleFromFile)
    @plugin[:os] = "linux"
    @plugin[:lsb] = Mash.new
    File.stub(:exists?).with("/etc/debian_version").and_return(false)
    File.stub(:exists?).with("/etc/redhat-release").and_return(false)
    File.stub(:exists?).with("/etc/gentoo-release").and_return(false)
    File.stub(:exists?).with("/etc/SuSE-release").and_return(false)
    File.stub(:exists?).with("/etc/arch-release").and_return(false)
    File.stub(:exists?).with("/etc/system-release").and_return(false)
    File.stub(:exists?).with("/etc/slackware-version").and_return(false)
    File.stub(:exists?).with("/etc/enterprise-release").and_return(false)
    File.stub(:exists?).with("/etc/oracle-release").and_return(false)
    File.stub(:exists?).with("/usr/bin/raspi-config").and_return(false)
  end
  
  describe "on lsb compliant distributions" do
    before(:each) do
      @plugin[:lsb][:id] = "Ubuntu"
      @plugin[:lsb][:release] = "8.04"
    end
    
    it "should set platform to lowercased lsb[:id]" do
      @plugin.run        
      @plugin[:platform].should == "ubuntu"
    end
    
    it "should set platform_version to lsb[:release]" do
      @plugin.run
      @plugin[:platform_version].should == "8.04"
    end

    it "should set platform to ubuntu and platform_family to debian [:lsb][:id] contains Ubuntu" do
      @plugin[:lsb][:id] = "Ubuntu"
      @plugin.run
      @plugin[:platform].should == "ubuntu"
      @plugin[:platform_family].should == "debian"
    end
    it "should set platform to linuxmint and platform_family to debian [:lsb][:id] contains LinuxMint" do
      @plugin[:lsb][:id] = "LinuxMint"
      @plugin.run
      @plugin[:platform].should == "linuxmint"
      @plugin[:platform_family].should == "debian"
    end
    it "should set platform to gcel and platform_family to debian [:lsb][:id] contains GCEL" do
      @plugin[:lsb][:id] = "GCEL"
      @plugin.run
      @plugin[:platform].should == "gcel"
      @plugin[:platform_family].should == "debian"
    end
    it "should set platform to debian and platform_family to debian [:lsb][:id] contains Debian" do
      @plugin[:lsb][:id] = "Debian"
      @plugin.run
      @plugin[:platform].should == "debian"
      @plugin[:platform_family].should == "debian"
    end
    it "should set platform to redhat and platform_family to rhel when [:lsb][:id] contains Redhat" do
      @plugin[:lsb][:id] = "RedHatEnterpriseServer"
      @plugin[:lsb][:release] = "5.7"
      @plugin.run
      @plugin[:platform].should == "redhat"
      @plugin[:platform_family].should == "rhel"
    end

    it "should set platform to amazon and platform_family to rhel when [:lsb][:id] contains Amazon" do
      @plugin[:lsb][:id] = "AmazonAMI"
      @plugin[:lsb][:release] = "2011.09"
      @plugin.run
      @plugin[:platform].should == "amazon"
      @plugin[:platform_family].should == "rhel"
    end

    it "should set platform to scientific when [:lsb][:id] contains ScientificSL" do
      @plugin[:lsb][:id] = "ScientificSL"
      @plugin[:lsb][:release] = "5.7"
      @plugin.run
      @plugin[:platform].should == "scientific"
    end
  end

  describe "on debian" do
    before(:each) do
      @plugin.lsb = nil
      File.should_receive(:exists?).with("/etc/debian_version").and_return(true)
    end

    it "should read the version from /etc/debian_version" do
      File.should_receive(:read).with("/etc/debian_version").and_return("5.0")
      @plugin.run
      @plugin[:platform_version].should == "5.0"
    end

    it "should correctly strip any newlines" do
      File.should_receive(:read).with("/etc/debian_version").and_return("5.0\n")
      @plugin.run
      @plugin[:platform_version].should == "5.0"
    end

    # Ubuntu has /etc/debian_version as well
    it "should detect Ubuntu as itself rather than debian" do
      @plugin[:lsb][:id] = "Ubuntu"
      @plugin[:lsb][:release] = "8.04"
      @plugin.run
      @plugin[:platform].should == "ubuntu"
    end

    # Raspbian is a debian clone
    it "should detect Raspbian as itself with debian as the family" do
      File.should_receive(:exists?).with("/usr/bin/raspi-config").and_return(true)
      File.should_receive(:read).with("/etc/debian_version").and_return("wheezy/sid")
      @plugin.run
      @plugin[:platform].should == "raspbian"
      @plugin[:platform_family].should == "debian"
    end
  end

  describe "on slackware" do
    before(:each) do
      @plugin.lsb = nil
      File.should_receive(:exists?).with("/etc/slackware-version").and_return(true)
    end

    it "should set platform and platform_family to slackware" do
      File.should_receive(:read).with("/etc/slackware-version").and_return("Slackware 12.0.0")
      @plugin.run
      @plugin[:platform].should == "slackware"
      @plugin[:platform_family].should == "slackware"
    end
  end
  
  describe "on arch" do
    before(:each) do
      @plugin.lsb = nil
      File.should_receive(:exists?).with("/etc/arch-release").and_return(true)
    end

    it "should set platform to arch and platform_family to arch" do
      @plugin.run
      @plugin[:platform].should == "arch"
      @plugin[:platform_family].should == "arch"
    end

  end
  
  describe "on gentoo" do
    before(:each) do
      @plugin.lsb = nil
      File.should_receive(:exists?).with("/etc/gentoo-release").and_return(true)
    end

    it "should set platform and platform_family to gentoo" do
      File.should_receive(:read).with("/etc/gentoo-release").and_return("Gentoo Base System release 1.20.1.1")
      @plugin.run
      @plugin[:platform].should == "gentoo"
      @plugin[:platform_family].should == "gentoo"
    end
  end

  describe "on redhat breeds" do
    describe "with lsb_release results" do
      it "should set the platform to redhat and platform_family to rhel even if the LSB name is something absurd but redhat like" do
        @plugin[:lsb][:id] = "RedHatEnterpriseServer"
        @plugin[:lsb][:release] = "6.1"
        @plugin.run
        @plugin[:platform].should == "redhat"
        @plugin[:platform_version].should == "6.1"
	@plugin[:platform_family].should == "rhel"
      end

      it "should set the platform to centos and platform_family to rhel" do
        @plugin[:lsb][:id] = "CentOS"
        @plugin[:lsb][:release] = "5.4"
        @plugin.run
        @plugin[:platform].should == "centos"
        @plugin[:platform_version].should == "5.4"
	@plugin[:platform_family].should == "rhel"

      end


      it "should set the platform_family to rhel if the LSB name is oracle-ish" do
        @plugin[:lsb][:id] = "EnterpriseEnterpriseServer"
        @plugin.run
	@plugin[:platform_family].should == "rhel"
      end

      it "should set the platform_family to rhel if the LSB name is amazon-ish" do
        @plugin[:lsb][:id] = "Amazon"
        @plugin.run
	@plugin[:platform_family].should == "rhel"
      end

      it "should set the platform_family to fedora if the LSB name is fedora-ish" do
        @plugin[:lsb][:id] = "Fedora"
        @plugin.run
	@plugin[:platform_family].should == "fedora"
      end

      it "should set the platform_family to redhat if the LSB name is scientific-ish" do
        @plugin[:lsb][:id] = "Scientific"
        @plugin.run
	@plugin[:platform_family].should == "rhel"
      end
    end
  
    describe "without lsb_release results" do
      before(:each) do
        @plugin.lsb = nil
        File.should_receive(:exists?).with("/etc/redhat-release").and_return(true)
      end
  
      it "should read the platform as centos and version as 5.3" do
        File.should_receive(:read).with("/etc/redhat-release").and_return("CentOS release 5.3")
        @plugin.run
        @plugin[:platform].should == "centos"
      end
  
      it "may be that someone munged Red Hat to be RedHat" do
        File.should_receive(:read).with("/etc/redhat-release").and_return("RedHat release 5.3")
        @plugin.run
        @plugin[:platform].should == "redhat"
        @plugin[:platform_version].should == "5.3"
      end
  
      it "should read the platform as redhat and version as 5.3" do
        File.should_receive(:read).with("/etc/redhat-release").and_return("Red Hat release 5.3")
        @plugin.run
        @plugin[:platform].should == "redhat"
        @plugin[:platform_version].should == "5.3"
      end
  
      it "should read the platform as fedora and version as 13 (rawhide)" do
        File.should_receive(:read).with("/etc/redhat-release").and_return("Fedora release 13 (Rawhide)")
        @plugin.run
        @plugin[:platform].should == "fedora"
        @plugin[:platform_version].should == "13 (rawhide)"
      end
      
      it "should read the platform as fedora and version as 10" do
        File.should_receive(:read).with("/etc/redhat-release").and_return("Fedora release 10")
        @plugin.run
        @plugin[:platform].should == "fedora"
        @plugin[:platform_version].should == "10"
      end
  
      it "should read the platform as fedora and version as 13 using to_i" do
        File.should_receive(:read).with("/etc/redhat-release").and_return("Fedora release 13 (Rawhide)")
        @plugin.run
        @plugin[:platform].should == "fedora"
        @plugin[:platform_version].to_i.should == 13
      end
    end
  end

  describe "on oracle enterprise linux" do
    describe "with lsb_results" do
      it "should read the platform as oracle and version as 5.7" do
        @plugin[:lsb][:id] = "EnterpriseEnterpriseServer"
        @plugin[:lsb][:release] = "5.7"
        File.stub(:exists?).with("/etc/redhat-release").and_return(true)
        File.stub(:read).with("/etc/redhat-release").and_return("Red Hat Enterprise Linux Server release 5.7 (Tikanga)")
        File.should_receive(:exists?).with("/etc/enterprise-release").and_return(true)
        File.should_receive(:read).with("/etc/enterprise-release").and_return("Enterprise Linux Enterprise Linux Server release 5.7 (Carthage)")
        @plugin.run
        @plugin[:platform].should == "oracle"
        @plugin[:platform_version].should == "5.7"
      end

      it "should read the platform as oracle and version as 6.1" do
        @plugin[:lsb][:id] = "OracleServer"
        @plugin[:lsb][:release] = "6.1"
        File.stub(:exists?).with("/etc/redhat-release").and_return(true)
        File.stub(:read).with("/etc/redhat-release").and_return("Red Hat Enterprise Linux Server release 6.1 (Santiago)")
        File.should_receive(:exists?).with("/etc/oracle-release").and_return(true)
        File.should_receive(:read).with("/etc/oracle-release").and_return("Oracle Linux Server release 6.1")
        @plugin.run
        @plugin[:platform].should == "oracle"
        @plugin[:platform_version].should == "6.1"
      end
    end

    describe "without lsb_results" do
      before(:each) do
        @plugin.lsb = nil
      end
 
      it "should read the platform as oracle and version as 5" do
        File.stub(:exists?).with("/etc/redhat-release").and_return(true)
        File.stub(:read).with("/etc/redhat-release").and_return("Enterprise Linux Enterprise Linux Server release 5 (Carthage)")
        File.should_receive(:exists?).with("/etc/enterprise-release").and_return(true)
        File.should_receive(:read).with("/etc/enterprise-release").and_return("Enterprise Linux Enterprise Linux Server release 5 (Carthage)")
        @plugin.run
        @plugin[:platform].should == "oracle"
        @plugin[:platform_version].should == "5"
      end

      it "should read the platform as oracle and version as 5.1" do
        File.stub(:exists?).with("/etc/redhat-release").and_return(true)
        File.stub(:read).with("/etc/redhat-release").and_return("Enterprise Linux Enterprise Linux Server release 5.1 (Carthage)")
        File.should_receive(:exists?).with("/etc/enterprise-release").and_return(true)
        File.should_receive(:read).with("/etc/enterprise-release").and_return("Enterprise Linux Enterprise Linux Server release 5.1 (Carthage)")
        @plugin.run
        @plugin[:platform].should == "oracle"
        @plugin[:platform_version].should == "5.1"
      end

      it "should read the platform as oracle and version as 5.7" do
        File.stub(:exists?).with("/etc/redhat-release").and_return(true)
        File.stub(:read).with("/etc/redhat-release").and_return("Red Hat Enterprise Linux Server release 5.7 (Tikanga)")
        File.should_receive(:exists?).with("/etc/enterprise-release").and_return(true)
        File.should_receive(:read).with("/etc/enterprise-release").and_return("Enterprise Linux Enterprise Linux Server release 5.7 (Carthage)")
        @plugin.run
        @plugin[:platform].should == "oracle"
        @plugin[:platform_version].should == "5.7"
      end

      it "should read the platform as oracle and version as 6.0" do
        File.stub(:exists?).with("/etc/redhat-release").and_return(true)
        File.stub(:read).with("/etc/redhat-release").and_return("Red Hat Enterprise Linux Server release 6.0 (Santiago)")
        File.should_receive(:exists?).with("/etc/oracle-release").and_return(true)
        File.should_receive(:read).with("/etc/oracle-release").and_return("Oracle Linux Server release 6.0")
        @plugin.run
        @plugin[:platform].should == "oracle"
        @plugin[:platform_version].should == "6.0"
      end
  
      it "should read the platform as oracle and version as 6.1" do
        File.stub(:exists?).with("/etc/redhat-release").and_return(true)
        File.stub(:read).with("/etc/redhat-release").and_return("Red Hat Enterprise Linux Server release 6.1 (Santiago)")
        File.should_receive(:exists?).with("/etc/oracle-release").and_return(true)
        File.should_receive(:read).with("/etc/oracle-release").and_return("Oracle Linux Server release 6.1")
        @plugin.run
        @plugin[:platform].should == "oracle"
        @plugin[:platform_version].should == "6.1"
      end
    end
  end

  describe "on suse" do
    before(:each) do
      File.should_receive(:exists?).with("/etc/SuSE-release").and_return(true)
    end

    describe "with lsb_release results" do
      before(:each) do
        @plugin[:lsb][:id] = "SUSE LINUX"
      end
      
      it "should read the platform as suse" do
        @plugin[:lsb][:release] = "12.1"
        File.should_receive(:read).with("/etc/SuSE-release").exactly(1).times.and_return("openSUSE 12.1 (x86_64)\nVERSION = 12.1\nCODENAME = Asparagus\n")
        @plugin.run
        @plugin[:platform].should == "suse"
        @plugin[:platform_version].should == "12.1"
        @plugin[:platform_family].should == "suse"
      end
    end

    describe "without lsb_release results" do
      before(:each) do
        @plugin.lsb = nil
      end
      
      it "should set platform and platform_family to suse and bogus verion to 10.0" do
        File.should_receive(:read).with("/etc/SuSE-release").at_least(:once).and_return("VERSION = 10.0")
        @plugin.run
        @plugin[:platform].should == "suse"
        @plugin[:platform_family].should == "suse"
      end
      
      it "should read the version as 10.1 for bogus SLES 10" do
        File.should_receive(:read).with("/etc/SuSE-release").and_return("SUSE Linux Enterprise Server 10 (i586)\nVERSION = 10\nPATCHLEVEL = 1\n")
        @plugin.run
        @plugin[:platform].should == "suse"
        @plugin[:platform_version].should == "10.1"
        @plugin[:platform_family].should == "suse"
      end
      
      it "should read the version as 11.2" do
        File.should_receive(:read).with("/etc/SuSE-release").and_return("SUSE Linux Enterprise Server 11.2 (i586)\nVERSION = 11\nPATCHLEVEL = 2\n")
        @plugin.run
        @plugin[:platform].should == "suse"
        @plugin[:platform_version].should == "11.2"
        @plugin[:platform_family].should == "suse"
      end
      
      it "[OHAI-272] should read the version as 11.3" do
        File.should_receive(:read).with("/etc/SuSE-release").exactly(1).times.and_return("openSUSE 11.3 (x86_64)\nVERSION = 11.3")
        @plugin.run
        @plugin[:platform].should == "suse"
        @plugin[:platform_version].should == "11.3"
        @plugin[:platform_family].should == "suse"
      end
      
      it "[OHAI-272] should read the version as 9.1" do
        File.should_receive(:read).with("/etc/SuSE-release").exactly(1).times.and_return("SuSE Linux 9.1 (i586)\nVERSION = 9.1")
        @plugin.run
        @plugin[:platform].should == "suse"
        @plugin[:platform_version].should == "9.1"
        @plugin[:platform_family].should == "suse"
      end
      
      it "[OHAI-272] should read the version as 11.4" do
        File.should_receive(:read).with("/etc/SuSE-release").exactly(1).times.and_return("openSUSE 11.4 (i586)\nVERSION = 11.4\nCODENAME = Celadon")
        @plugin.run
        @plugin[:platform].should == "suse"
        @plugin[:platform_version].should == "11.4"
        @plugin[:platform_family].should == "suse"
      end
    end
  end

end

