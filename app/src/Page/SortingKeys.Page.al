namespace SamueleCelebron.ObjectLauncher;

using System.Reflection;

page 50101 "Sorting Keys"
{
    ApplicationArea = All;
    Caption = 'Sorting Keys';
    PageType = List;
    SourceTable = "Key";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(KeyList)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the sequential number identifying this key within the table definition.';
                }
                field("Key"; Rec."Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the comma-separated list of field names that compose this sorting key.';
                }
                field(Descending; Rec.Unique)
                {
                    ApplicationArea = All;
                    Caption = 'Descending';
                    ToolTip = 'Indicates whether the records should be sorted in descending order when using this key.';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.TableNo := GlobalTableNumber;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        TempSelectedKey := Rec;
        TempSelectedKey.Insert();
    end;

    /// <summary>
    /// Sets the table number and initializes the key list from either
    /// a previously stored temporary key set or from the system Key table.
    /// </summary>
    /// <param name="TableNumber">The ID of the table whose keys should be loaded.</param>
    /// <param name="TempKey">A temporary Key record holding previously selected keys, or empty to load from the system table.</param>
    procedure SetTableNo(TableNumber: Integer; var TempKey: Record "Key" temporary)
    var
        KeyRecord: Record "Key";
    begin
        GlobalTableNumber := TableNumber;
        if TempKey.IsEmpty then begin
            KeyRecord.SetRange(TableNo, GlobalTableNumber);
            KeyRecord.SetRange(Enabled, true);
            KeyRecord.SetFilter("Key", '<>%1', '$systemId');
            KeyRecord.SetLoadFields(TableNo, "No.", "Key", Unique, Enabled);
            if KeyRecord.FindSet() then
                repeat
                    Rec.Init();
                    Rec := KeyRecord;
                    Rec.Insert();
                until KeyRecord.Next() = 0;
        end else begin
            if TempKey.FindSet() then
                repeat
                    Rec.Init();
                    Rec := TempKey;
                    Rec.Insert();
                until TempKey.Next() = 0;
        end;

        if Rec.FindFirst() then;
    end;

    /// <summary>
    /// Copies all keys currently shown on the page into the provided temporary record set.
    /// </summary>
    /// <param name="TempKey">The temporary Key record to populate with the current key list.</param>
    procedure GetTempKey(var TempKey: Record "Key" temporary)
    begin
        TempKey.Reset();
        TempKey.DeleteAll();

        if Rec.FindSet() then
            repeat
                TempKey := Rec;
                TempKey.Insert();
            until Rec.Next() = 0;
    end;

    /// <summary>
    /// Returns the key record that was selected by the user when closing the page.
    /// </summary>
    /// <param name="TempKey">The temporary Key record to receive the selected key.</param>
    procedure GetSelectedRec(var TempKey: Record "Key" temporary)
    begin
        TempKey := TempSelectedKey;
        TempKey.Insert();
    end;

    var
        TempSelectedKey: Record "Key" temporary;
        GlobalTableNumber: Integer;
}
