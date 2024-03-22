page 50101 "Sorting keys"
{
    PageType = List;
    SourceTable = Key;
    SourceTableTemporary = true;
    Caption = 'Sorting keys';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field("Key"; Rec."Key")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the Key field.';
                }
                field(Descending; Rec.Unique)
                {
                    Caption = 'Descending';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Descending field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;
                ToolTip = 'Executes the ActionName action.';
                trigger OnAction();
                begin

                end;
            }
        }
    }


    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.TableNo := GlobalTableID;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        TempSelectedKey := Rec;
        TempSelectedKey.Insert();
    end;

    procedure SetTableNo(TableNo_par: integer; var TempKey: record "Key" temporary)
    var
        KeyRec: record "Key";
    begin
        GlobalTableID := TableNo_par;
        if TempKey.IsEmpty then begin
            KeyRec.SetRange(TableNo, GlobalTableID);
            KeyRec.SetRange(Enabled, true);
            KeyRec.SetFilter(key, '<>%1', '$systemId');
            if KeyRec.FindSet() then
                repeat
                    rec.Init();
                    Rec := KeyRec;
                    rec.Insert();
                until KeyRec.Next() = 0;
        end else begin
            if TempKey.FindSet() then
                repeat
                    rec.Init();
                    Rec := TempKey;
                    rec.Insert();
                until TempKey.Next() = 0;
        end;

        if Rec.FindFirst() then;
    end;

    procedure GetTempKey(var TempKey: record "Key" temporary)
    var
    begin
        TempKey.Reset();
        TempKey.DeleteAll();

        if Rec.FindSet() then
            repeat
                TempKey := Rec;
                TempKey.Insert();
            until Rec.Next() = 0;
    end;

    procedure GetSelectedRec(var TempKey: record "Key" temporary)
    var
    begin
        TempKey := TempSelectedKey;
        TempKey.Insert();
    end;

    var
        GlobalTableID: Integer;
        TempSelectedKey: record "Key" temporary;
}