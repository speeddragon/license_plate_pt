defmodule LicensePlatePT.Information.Type1Test do
  @moduledoc false

  @subject LicensePlatePT.Information.Type1

  use ExUnit.Case, async: true

  doctest @subject

  describe "get_years_by_letters" do
    assert @subject.get_years_by_letters("GJ") == [84]
  end

  describe "get_years/1" do
    test "Sequential license plate, start in middle" do
      assert @subject.get_year("PO-50-00") == 77
    end

    test "Sequential license plate, just before middle" do
      assert @subject.get_year("PO-49-99") == 76
    end

    test "Non-sequential, special 1000" do
      assert @subject.get_year("LF-01-23") == 82
    end

    test "Non-sequential, after special 1000" do
      assert @subject.get_year("LF-54-99") == 70
    end

    test "Non-sequential, after special 1000, middle onwards" do
      assert @subject.get_year("LF-55-00") == 71
    end

    test "No information available" do
      refute @subject.get_year("MA-12-23")
    end
  end
end
