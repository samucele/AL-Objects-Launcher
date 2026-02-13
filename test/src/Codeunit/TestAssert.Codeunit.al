namespace SamueleCelebron.ObjectLauncher;

/// <summary>
/// Minimal assertion helper for test codeunits.
/// Replaces Library Assert dependency to avoid requiring Tests-TestLibraries package.
/// </summary>
codeunit 50149 "Test Assert"
{
    procedure IsTrue(Condition: Boolean; Message: Text)
    begin
        if not Condition then
            Error('Assert.IsTrue failed: %1', Message);
    end;

    procedure IsFalse(Condition: Boolean; Message: Text)
    begin
        if Condition then
            Error('Assert.IsFalse failed: %1', Message);
    end;

    procedure AreEqual(Expected: Variant; Actual: Variant; Message: Text)
    begin
        if Format(Expected) <> Format(Actual) then
            Error('Assert.AreEqual failed: Expected <%1>, Actual <%2>. %3', Expected, Actual, Message);
    end;

    procedure AreNotEqual(NotExpected: Variant; Actual: Variant; Message: Text)
    begin
        if Format(NotExpected) = Format(Actual) then
            Error('Assert.AreNotEqual failed: Both values are <%1>. %2', Actual, Message);
    end;

    procedure ExpectedError(ExpectedErrorText: Text)
    begin
        if StrPos(GetLastErrorText(), ExpectedErrorText) = 0 then
            Error('Assert.ExpectedError failed: Expected error containing <%1>, but got <%2>', ExpectedErrorText, GetLastErrorText());
    end;
}
