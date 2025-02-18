require "../../../spec_helper"

module Ameba
  subject = Rule::Style::VariableNames.new

  private def it_reports_var_name(name, value, expected)
    it "reports variable name #{expected}" do
      rule = Rule::Style::VariableNames.new
      expect_issue rule, <<-CRYSTAL, name: name
          %{name} = #{value}
        # ^{name} error: Var name should be underscore-cased: #{expected}, not %{name}
        CRYSTAL
    end
  end

  describe Rule::Style::VariableNames do
    it "passes if var names are underscore-cased" do
      expect_no_issues subject, <<-CRYSTAL
        class Greeting
          @@default_greeting = "Hello world"

          def initialize(@custom_greeting = nil)
          end

          def print_greeting
            greeting = @custom_greeting || @@default_greeting
            puts greeting
          end
        end
        CRYSTAL
    end

    it_reports_var_name "myBadNamedVar", "1", "my_bad_named_var"
    it_reports_var_name "wrong_Name", "'y'", "wrong_name"

    it "reports instance variable name" do
      expect_issue subject, <<-CRYSTAL
        class Greeting
          def initialize(@badNamed = nil)
                       # ^ error: Var name should be underscore-cased: @bad_named, not @badNamed
          end
        end
        CRYSTAL
    end

    it "reports method with multiple instance variables" do
      expect_issue subject, <<-CRYSTAL
        class Location
          def at(@startLocation = nil, @endLocation = nil)
               # ^ error: Var name should be underscore-cased: @start_location, not @startLocation
                                     # ^ error: Var name should be underscore-cased: @end_location, not @endLocation
          end
        end
        CRYSTAL
    end

    it "reports class variable name" do
      expect_issue subject, <<-CRYSTAL
        class Greeting
          @@defaultGreeting = "Hello world"
        # ^^^^^^^^^^^^^^^^^ error: Var name should be underscore-cased: @@default_greeting, not @@defaultGreeting
        end
        CRYSTAL
    end

    it "reports rule, pos and message" do
      s = Source.new %(
        badName = "Yeah"
      ), "source.cr"
      subject.catch(s).should_not be_valid
      issue = s.issues.first
      issue.rule.should_not be_nil
      issue.location.to_s.should eq "source.cr:1:1"
      issue.end_location.to_s.should eq "source.cr:1:7"
      issue.message.should eq(
        "Var name should be underscore-cased: bad_name, not badName"
      )
    end
  end
end
