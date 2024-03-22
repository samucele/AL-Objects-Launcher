page 50102 "Table Data Editor"
{
    PageType = List;
    SourceTable = Integer;
    SourceTableTemporary = true;
    Caption = 'Table Data Editor';
    Permissions =
    tabledata "Sales Invoice Header" = rimd,
    tabledata "Sales Invoice Line" = rimd,
    tabledata "Sales Cr.Memo header" = rimd,
    tabledata "Sales Cr.Memo Line" = rimd,
    tabledata "Sales Shipment Header" = rimd,
    tabledata "Sales Shipment Line" = rimd,
    tabledata "Purch. Rcpt. Header" = rimd,
    tabledata "Purch. Rcpt. Line" = rimd,
    tabledata "Purch. Inv. Header" = rimd,
    tabledata "Purch. Inv. Line" = rimd,
    tabledata "Purch. Cr. Memo Hdr." = rimd,
    tabledata "Purch. Cr. Memo Line" = rimd,
    tabledata "G/L Entry" = rimd,
    tabledata "Cust. Ledger Entry" = rimd,
    tabledata "Vendor Ledger Entry" = rimd,
    tabledata "G/L Register" = rimd,
    tabledata "G/L Entry - VAT Entry Link" = rimd,
    tabledata "VAT Entry" = rimd,
    tabledata "Detailed Cust. Ledg. Entry" = rimd,
    tabledata "Detailed Vendor Ledg. Entry" = rimd,
    tabledata "CV Ledger Entry Buffer" = rimd,
    tabledata "Detailed CV Ledg. Entry Buffer" = rimd,
    tabledata "Post Value Entry to G/L" = rimd,
    tabledata "G/L - Item Ledger Relation" = rimd,
    tabledata "Item Ledger Entry" = rimd,
    tabledata "Value Entry" = rimd;

    layout
    {
        area(Content)
        {
            group(Parameters)
            {
                field(TableID; TableID)
                {
                    Caption = 'Table ID';
                    TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(TableData));
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table ID field.';
                    trigger OnValidate()
                    begin
                        ClearFilter();
                        LoadCaptions();
                        LoadRecords();
                    end;
                }
                field(TableName; GetTableName())
                {
                    Caption = 'Table Name';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field.';
                }

                field(RecordCount; RecordCount)
                {
                    Caption = 'Record Count';
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Record Count field.';
                }
                field(CompanyName; CompanyName)
                {
                    Caption = 'Company';
                    TableRelation = Company;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company field.';
                    trigger OnValidate()
                    begin
                        if CompanyName = '' then
                            CompanyName := Rec.CurrentCompany;

                        LoadRecords();
                    end;
                }
                field(ValidateFields; ValidateFields)
                {
                    Caption = 'Validate';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Validate field.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(RunTriggers; RunTriggers)
                {
                    Caption = 'Run triggers';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Run triggers field.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
            }
            repeater(GroupName)
            {
                field(KeyMatrixData1; KeyMatrixData[1])
                {
                    CaptionClass = KeyCaptionData[1];
                    Enabled = false;
                    Visible = KeyControlVisibility1;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the KeyMatrixData[1] field.';
                }
                field(KeyMatrixData2; KeyMatrixData[2])
                {
                    CaptionClass = KeyCaptionData[2];
                    Enabled = false;
                    Visible = KeyControlVisibility2;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the KeyMatrixData[2] field.';
                }
                field(KeyMatrixData3; KeyMatrixData[3])
                {
                    CaptionClass = KeyCaptionData[3];
                    Enabled = false;
                    Visible = KeyControlVisibility3;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the KeyMatrixData[3] field.';
                }
                field(KeyMatrixData4; KeyMatrixData[4])
                {
                    CaptionClass = KeyCaptionData[4];
                    Enabled = false;
                    Visible = KeyControlVisibility4;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the KeyMatrixData[4] field.';
                }
                field(KeyMatrixData5; KeyMatrixData[5])
                {
                    CaptionClass = KeyCaptionData[5];
                    Enabled = false;
                    Visible = KeyControlVisibility5;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the KeyMatrixData[5] field.';
                }
                field(MatrixData1; MatrixData[GetControlSetNr(1)])
                {
                    CaptionClass = CaptionData[GetControlSetNr(1)];
                    Visible = MatrixDataVisibility1;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the MatrixData[GetControlSetNr(1)] field.';
                    trigger OnValidate()
                    begin
                        ChangeValues(GetControlSetNr(1));
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldLookup(GetControlSetNr(1));
                    end;
                }
                field(MatrixData2; MatrixData[GetControlSetNr(2)])
                {
                    CaptionClass = CaptionData[GetControlSetNr(2)];
                    Visible = MatrixDataVisibility2;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the MatrixData[GetControlSetNr(2)] field.';
                    trigger OnValidate()
                    begin
                        ChangeValues(GetControlSetNr(2));
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldLookup(GetControlSetNr(2));
                    end;
                }
                field(MatrixData3; MatrixData[GetControlSetNr(3)])
                {
                    CaptionClass = CaptionData[GetControlSetNr(3)];
                    Visible = MatrixDataVisibility3;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the MatrixData[GetControlSetNr(3)] field.';
                    trigger OnValidate()
                    begin
                        ChangeValues(GetControlSetNr(3));
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldLookup(GetControlSetNr(3));
                    end;
                }
                field(MatrixData4; MatrixData[GetControlSetNr(4)])
                {
                    CaptionClass = CaptionData[GetControlSetNr(4)];
                    Visible = MatrixDataVisibility4;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the MatrixData[GetControlSetNr(4)] field.';
                    trigger OnValidate()
                    begin
                        ChangeValues(GetControlSetNr(4));
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldLookup(GetControlSetNr(4));
                    end;
                }
                field(MatrixData5; MatrixData[GetControlSetNr(5)])
                {
                    CaptionClass = CaptionData[GetControlSetNr(5)];
                    Visible = MatrixDataVisibility5;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the MatrixData[GetControlSetNr(5)] field.';
                    trigger OnValidate()
                    begin
                        ChangeValues(GetControlSetNr(5));
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldLookup(GetControlSetNr(5));
                    end;
                }
                field(MatrixData6; MatrixData[GetControlSetNr(6)])
                {
                    CaptionClass = CaptionData[GetControlSetNr(6)];
                    Visible = MatrixDataVisibility6;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the MatrixData[GetControlSetNr(6)] field.';
                    trigger OnValidate()
                    begin
                        ChangeValues(GetControlSetNr(6));
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldLookup(GetControlSetNr(6));
                    end;
                }
                field(MatrixData7; MatrixData[GetControlSetNr(7)])
                {
                    CaptionClass = CaptionData[GetControlSetNr(7)];
                    Visible = MatrixDataVisibility7;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the MatrixData[GetControlSetNr(7)] field.';
                    trigger OnValidate()
                    begin
                        ChangeValues(GetControlSetNr(7));
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldLookup(GetControlSetNr(7));
                    end;
                }

                field(MatrixData8; MatrixData[GetControlSetNr(8)])
                {
                    CaptionClass = CaptionData[GetControlSetNr(8)];
                    Visible = MatrixDataVisibility8;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the MatrixData[GetControlSetNr(8)] field.';
                    trigger OnValidate()
                    begin
                        ChangeValues(GetControlSetNr(8));
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldLookup(GetControlSetNr(8));
                    end;
                }
                field(MatrixData9; MatrixData[GetControlSetNr(9)])
                {
                    CaptionClass = CaptionData[GetControlSetNr(9)];
                    Visible = MatrixDataVisibility9;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the MatrixData[GetControlSetNr(9)] field.';
                    trigger OnValidate()
                    begin
                        ChangeValues(GetControlSetNr(9));
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldLookup(GetControlSetNr(9));
                    end;
                }
                field(MatrixData10; MatrixData[GetControlSetNr(10)])
                {
                    CaptionClass = CaptionData[GetControlSetNr(10)];
                    Visible = MatrixDataVisibility10;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the MatrixData[GetControlSetNr(10)] field.';
                    trigger OnValidate()
                    begin
                        ChangeValues(GetControlSetNr(10));
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        FieldLookup(GetControlSetNr(10));
                    end;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(FirstSet)
            {
                Caption = 'First Set';
                ApplicationArea = All;
                Image = PreviousSet;
                ToolTip = 'Executes the First Set action.';
                trigger OnAction()
                begin
                    LoadFirstSet();
                end;
            }
            action(PrevSet)
            {
                Caption = 'Previous Set';
                ApplicationArea = All;
                Image = PreviousRecord;
                ToolTip = 'Executes the Previous Set action.';
                trigger OnAction();
                begin
                    LoadPrevSet();
                end;
            }
            action(NextSet)
            {
                Caption = 'Next Set';
                ApplicationArea = All;
                Image = NextRecord;
                ToolTip = 'Executes the Next Set action.';
                trigger OnAction();
                begin
                    LoadNextSet();
                end;
            }
            action(LastSet)
            {
                Caption = 'Last Set';
                ApplicationArea = All;
                Image = NextSet;
                ToolTip = 'Executes the Last Set action.';
                trigger OnAction()
                begin
                    LoadLastSet();
                end;
            }
            action(TableFilters)
            {
                Caption = 'Table Filters';
                ApplicationArea = All;
                Image = EditFilter;
                ToolTip = 'Executes the Table Filters action.';
                trigger OnAction()
                begin
                    OpenFilters();
                end;
            }
            action(FieldsSelection)
            {
                Caption = 'Fields Selection';
                ApplicationArea = All;
                Image = SelectField;
                ToolTip = 'Executes the Fields Selection action.';
                trigger OnAction()
                begin
                    OpenFieldsSelection();
                end;
            }
            action(ResetPage)
            {
                Caption = 'Reset Page';
                ApplicationArea = All;
                Image = ClearFilter;
                ToolTip = 'Executes the Reset Page action.';
                trigger OnAction()
                begin
                    ClearFilter();
                end;
            }
            Action(OpenRec)
            {
                Caption = 'Open Record';
                ApplicationArea = All;
                Image = ViewPage;
                Scope = Repeater;
                ToolTip = 'Executes the Open Record action.';
                trigger OnAction()
                begin
                    OpenPageRecord();
                end;
            }
            action(SelectKey)
            {
                Caption = 'Select Sorting Key';
                ApplicationArea = All;
                Image = EncryptionKeys;
                ToolTip = 'Executes the Select Sorting Key action.';
                trigger OnAction()
                begin
                    SelectTableKey();
                end;
            }
            action(ExportToExcelCtrl)
            {
                Caption = 'Export To Excel';
                ApplicationArea = All;
                Image = ExportToExcel;
                ToolTip = 'Executes the Export To Excel action.';
                trigger OnAction()
                begin
                    ExportToExcel();
                end;
            }
            action(DeleteAll)
            {
                Caption = 'Delete All';
                ApplicationArea = all;
                Image = DeleteAllBreakpoints;
                ToolTip = 'Executes the Delete All action.';
                trigger OnAction()
                begin
                    DeleteAllRecords();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(FirstSet_Promoted; FirstSet)
                {
                }
                actionref(PrevSet_Promoted; PrevSet)
                {
                }
                actionref(NextSet_Promoted; NextSet)
                {
                }
                actionref(LastSet_Promoted; LastSet)
                {
                }
                actionref(TableFilters_Promoted; TableFilters)
                {
                }
                actionref(FieldsSelection_Promoted; FieldsSelection)
                {
                }
                actionref(ResetPage_Promoted; ResetPage)
                {
                }
                actionref(OpenRec_Promoted; OpenRec)
                {
                }
                actionref(SelectKey_Promoted; SelectKey)
                {
                }
                actionref(ExportToExcelCtrl_Promoted; ExportToExcelCtrl)
                {
                }
                actionref(DeleteAll_Promoted; DeleteAll)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CompanyName := Rec.CurrentCompany;
        ValidateFields := true;
        RunTriggers := true;
        LoadCaptions();
        SetKeyControlVisibility();
        SetMatrixDataVisibility();
        LoadRecords();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(MatrixData);
        Clear(KeyMatrixData);
        Rec.Number := RecordCount + 1;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        InsertRecord();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        DeleteRecord();
        CurrPage.Update();
    end;

    trigger OnAfterGetRecord()
    begin
        LoadValues();
        SetKeyControlVisibility();
        SetMatrixDataVisibility();
    end;

    procedure SetTableID(TableID_par: Integer)
    var
    begin
        TableID := TableID_par;
    end;

    local procedure LoadRecords()
    var
        RecRef: RecordRef;
        iter: Integer;
    begin
        rec.Reset();
        rec.DeleteAll();
        Clear(RecDictionary);
        Clear(MatrixData);
        Clear(KeyMatrixData);

        PrepareRecRef(RecRef);
        RecordCount := RecRef.Count;
        if RecRef.FindSet() then
            repeat
                iter += 1;
                rec.Init();
                Rec.Number := iter;
                rec.Insert();

                RecDictionary.Add(iter, RecRef.RecordId);
            until RecRef.Next() = 0;
        if Rec.FindFirst() then;
    end;

    local procedure PrepareRecRef(var RecRef: RecordRef)
    var
    begin
        OpenRecref(RecRef);
        SetFiltersOnRecRef(RecRef);
        SetKeyOnRecRef(RecRef);
    end;

    local procedure GetFilteredField(var Field: record Field)
    var
    begin
        Field.SetRange(TableNo, TableID);
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
        Field.SetRange(Enabled, true);
    end;

    local procedure LoadCaptions()
    var
        Field: Record "Field";
        Iter: Integer;
        KeyIter: Integer;
    begin
        clear(CaptionData);
        clear(FieldDictionary);
        clear(KeyCaptionData);

        GetFilteredField(Field);
        if Field.FindSet() then
            repeat
                if not SkipField(Field) then begin
                    Iter += 1;
                    CaptionData[Iter] := Field."Field Caption";
                    FieldDictionary.Add(Iter, Field."No.");

                    if Field.IsPartOfPrimaryKey then begin
                        KeyIter += 1;
                        KeyCaptionData[KeyIter] := Field."Field Caption";
                    end;
                end;
            until (Field.Next() = 0) or (Iter = ArrayLen(CaptionData));
    end;

    local procedure LoadValues()
    var
        Field: Record "Field";
        Iter: Integer;
        KeyIter: Integer;
        fRef: FieldRef;
        RecRef: RecordRef;
        RecID: RecordId;
    begin
        Clear(MatrixData);
        Clear(KeyMatrixData);
        GetRecRef(RecRef);
        GetFilteredField(Field);
        if field.FindSet() then
            repeat
                if not SkipField(Field) then begin
                    Iter += 1;
                    fRef := RecRef.Field(Field."No.");
                    if Field.Class = Field.Class::FlowField then
                        fRef.CalcField();

                    MatrixData[Iter] := Format(fRef.Value);

                    if Field.IsPartOfPrimaryKey then begin
                        KeyIter += 1;
                        KeyMatrixData[KeyIter] := Format(fRef.Value);
                    end;
                end;
            until (Field.Next() = 0) or (Iter = ArrayLen(MatrixData));
    end;

    local procedure SkipField(var Field: record Field): Boolean
    var
    begin
        TempSelectedField.Reset();
        if TempSelectedField.IsEmpty then
            exit(false);

        if Field.IsPartOfPrimaryKey then
            exit(false);

        TempSelectedField.SetRange("No.", Field."No.");
        exit(TempSelectedField.IsEmpty);
    end;

    local procedure GetRecRef(var RecRef: recordref): Boolean
    var
        RecID: RecordId;
    begin
        OpenRecref(RecRef);
        if not RecDictionary.Get(Rec.Number, RecID) then
            exit(false);

        exit(RecRef.Get(RecID));
    end;

    local procedure OpenRecref(var RecRef: recordref)
    var
    begin
        RecRef.Open(TableID, false, CompanyName);
    end;

    local procedure GetfRef(var fRef: fieldref; var RecRef: recordref; Iter: Integer)
    var
    begin
        fRef := RecRef.Field(GetFieldNo(Iter));
    end;

    local procedure GetFieldNo(Iter: Integer) FieldNo: Integer
    var
    begin
        FieldDictionary.Get(Iter, FieldNo);
    end;

    local procedure ChangeValues(iter: Integer)
    var
        RecRef: recordref;
        fRef: FieldRef;
        Value: Variant;
        Field: Record Field;
        TypeHelper: Codeunit "Type Helper";
        DotNet_CultureInfo: codeunit "DotNet_CultureInfo";
        RecExists: Boolean;
        OldValue: Variant;
        IsHandled: Boolean;
    begin
        RecExists := GetRecRef(RecRef);
        GetfRef(fRef, RecRef, iter);
        Field.Get(TableID, GetFieldNo(iter));

        if (not Field.Enabled) or (Field.Class <> Field.Class::Normal) then
            Error('');

        Value := fRef.Value;
        OldValue := Value;

        case Field.Type of
            Field.type::Code, Field.Type::Text:
                Value := MatrixData[iter];
            field.Type::Option:
                Value := TypeHelper.GetOptionNo(MatrixData[iter], fRef.OptionCaption);
            field.type::Boolean:
                Value := EvaluateBoolean(iter);
            else begin
                TypeHelper.Evaluate(Value, MatrixData[iter], '', DotNet_CultureInfo.CurrentCultureName());
            end;
        end;

        if ValidateFields then
            fRef.Validate(Value)
        else
            fRef.value(Value);

        if RecExists then begin
            if Field.IsPartOfPrimaryKey then
                RenameRecRef(RecRef, fRef, OldValue)
            else begin
                OnBeforeGenericDatabaseWrite(RecRef, RunTriggers, OperationType::Modify, IsHandled);
                if not IsHandled then
                    RecRef.Modify(RunTriggers);
            end;
        end else begin
            OnBeforeGenericDatabaseWrite(RecRef, RunTriggers, OperationType::Insert, IsHandled);
            if not IsHandled then
                RecRef.Insert(RunTriggers);
            RecDictionary.Add(Rec.Number, RecRef.RecordId);
            CountRec();
        end;

        LoadValues();
    end;

    local procedure RenameRecRef(var RecRef: RecordRef; var fRefPKey: FieldRef; OldValue: Variant)
    var
        fRef: FieldRef;
        Field: Record "Field";
        Var1: Variant;
        Var2: Variant;
        Var3: Variant;
        Var4: Variant;
        Var5: Variant;
        Iter: Integer;
        IsHandled: Boolean;
    begin
        GetFilteredField(Field);
        Field.SetRange(IsPartOfPrimaryKey, true);
        if Field.FindSet() then
            repeat
                fRef := RecRef.Field(Field."No.");
                Iter += 1;
                case iter of
                    1:
                        Var1 := fRef.Value;
                    2:
                        Var2 := fRef.Value;
                    3:
                        Var3 := fRef.Value;
                    4:
                        Var4 := fRef.Value;
                    5:
                        Var5 := fRef.Value;
                end;
            until Field.Next() = 0;

        fRefPKey.Value(OldValue);

        OnBeforeGenericDatabaseRename(RecRef, Field.Count, Var1, Var2, Var3, Var4, Var5, IsHandled);
        if not IsHandled then
            case Field.Count of
                1:
                    RecRef.Rename(Var1);
                2:
                    RecRef.Rename(Var1, Var2);
                3:
                    RecRef.Rename(Var1, Var2, Var3);
                4:
                    RecRef.Rename(Var1, Var2, Var3, Var4);
                5:
                    RecRef.Rename(Var1, Var2, Var3, Var4, Var5);
            end;
        RecDictionary.Set(Rec.Number, RecRef.RecordId);
    end;

    local procedure DeleteRecord()
    var
        RecRef: RecordRef;
        IsHandled: Boolean;
    begin
        GetRecRef(RecRef);
        OnBeforeGenericDatabaseWrite(RecRef, RunTriggers, OperationType::Delete, IsHandled);
        if not IsHandled then
            RecRef.Delete(RunTriggers);
        RecDictionary.Remove(rec.Number);
        Clear(MatrixData);
        Clear(KeyMatrixData);
        CountRec();
    end;

    local procedure InsertRecord()
    var
    begin

    end;

    local procedure LoadNextSet()
    begin
        MatrixSetNr += 1;
        if CaptionData[GetControlSetNr(1)] = '' then begin
            MatrixSetNr -= 1;
            exit;
        end;

        CurrPage.Update();
    end;

    local procedure LoadPrevSet()
    var
    begin
        if (MatrixSetNr - 1) < 0 then
            exit;

        MatrixSetNr -= 1;
        CurrPage.Update();
    end;

    local procedure GetControlSetNr(Nr: Integer): Integer
    var
    begin
        exit((MatrixSetNr * 10) + Nr);
    end;

    local procedure SetKeyControlVisibility(): Boolean
    var
    begin
        KeyControlVisibility1 := MatrixSetNr > 0;
        KeyControlVisibility2 := (MatrixSetNr > 0) and (KeyCaptionData[2] <> '');
        KeyControlVisibility3 := (MatrixSetNr > 0) and (KeyCaptionData[3] <> '');
        KeyControlVisibility4 := (MatrixSetNr > 0) and (KeyCaptionData[4] <> '');
        KeyControlVisibility5 := (MatrixSetNr > 0) and (KeyCaptionData[5] <> '');
    end;

    local procedure FieldLookup(iter: Integer)
    var
        Field: record Field;
        TableRelationsMetadata: Record "Table Relations Metadata";
    begin
        Field.Get(TableID, GetFieldNo(iter));

        case true of
            (Field.Type = field.type::Option):
                FieldOptionLookup(iter);
            (Field.type in [Field.Type::Date, Field.Type::DateTime]):
                FieldDateLookup(iter, Field);
            (Field.type = field.type::Boolean):
                FieldBooleanLookup(iter);
            FieldHaveRelation(Field, TableRelationsMetadata):
                FieldRelationLoolup(iter, TableRelationsMetadata);
        end
    end;

    local procedure FieldHaveRelation(var Field: record Field; var TableRelationsMetadata: Record "Table Relations Metadata"): Boolean
    var
    begin
        TableRelationsMetadata.SetRange("Table ID", TableID);
        TableRelationsMetadata.SetRange("Field No.", Field."No.");
        TableRelationsMetadata.SetFilter("Related Table ID", '<>%1', 0);
        exit(TableRelationsMetadata.FindFirst());
    end;

    local procedure FieldOptionLookup(iter: Integer)
    var
        RecRef: RecordRef;
        fRef: FieldRef;
        Return: Integer;
        TypeHelper: Codeunit "Type Helper";
        DefaultNumber: Integer;
    begin
        GetRecRef(RecRef);
        GetfRef(fRef, RecRef, iter);
        DefaultNumber := TypeHelper.GetOptionNo(MatrixData[iter], fRef.OptionCaption) + 1;
        Return := StrMenu(fRef.OptionCaption, DefaultNumber);
        if Return = 0 then
            exit;

        MatrixData[iter] := SelectStr(Return, fRef.OptionCaption);
        ChangeValues(iter);
    end;

    local procedure FieldRelationLoolup(iter: Integer; var TableRelationsMetadata: Record "Table Relations Metadata")
    var
        RecRef: RecordRef;
        fRef: FieldRef;
        RelationRecRef: RecordRef;
        RelationfRef: FieldRef;
        VariantRec: Variant;
        Return: Action;
    begin
        GetRecRef(RecRef);
        GetfRef(fRef, RecRef, iter);

        CheckRelationsCondition(TableRelationsMetadata, RecRef);
        RelationRecRef.Open(TableRelationsMetadata."Related Table ID", false, CompanyName);
        RelationfRef := RelationRecRef.Field(TableRelationsMetadata."Related Field No.");
        VariantRec := RelationRecRef;
        Return := page.RunModal(0, VariantRec);
        if not (Return in [Action::OK, Action::LookupOK]) then
            exit;

        RelationRecRef := VariantRec;
        RelationfRef := RelationRecRef.Field(TableRelationsMetadata."Related Field No.");
        MatrixData[iter] := RelationfRef.Value;
        ChangeValues(iter);
    end;

    local procedure CheckRelationsCondition(var TableRelationsMetadata: Record "Table Relations Metadata"; var RecRef: RecordRef)
    var
        ConditionfRef: FieldRef;
    begin
        if TableRelationsMetadata.Count = 1 then
            exit;

        repeat
            ConditionfRef := RecRef.Field(TableRelationsMetadata."Condition Field No.");

            case TableRelationsMetadata."Condition Type" of
                TableRelationsMetadata."Condition Type"::CONST:
                    if format(ConditionfRef.Value) = TableRelationsMetadata."Condition Value" then
                        exit;
            end;
        until TableRelationsMetadata.Next() = 0;
    end;

    local procedure OpenFilters()
    var
        TableFilter: Page "Table Filter";
    begin
        TableFilter.SetSourceTable(TableFiltersText, TableID, '');
        TableFilter.RunModal();
        TableFilter.GetFilterFieldsList(TempTableFilter);
        TableFiltersText := TableFilter.CreateTextTableFilter(false);
        LoadRecords();
    end;

    local procedure SetFiltersOnRecRef(var RecRef: RecordRef)
    var
        fRef: FieldRef;
    begin
        if TempTableFilter.FindSet() then
            repeat
                fRef := RecRef.Field(TempTableFilter."Field Number");
                fRef.SetFilter(TempTableFilter."Field Filter");
            until TempTableFilter.Next() = 0;
    end;

    local procedure ClearFilter()
    begin
        TempTableFilter.Reset();
        TempTableFilter.DeleteAll();
        Clear(TableFiltersText);
        TempSelectedField.Reset();
        TempSelectedField.DeleteAll();
        TempSelectedKey.Reset();
        TempSelectedKey.DeleteAll();
        Clear(MatrixSetNr);
        LoadCaptions();
        LoadRecords();
        CurrPage.Update(false);
    end;

    local procedure LoadFirstSet()
    begin
        MatrixSetNr := 0;
        CurrPage.Update();
    end;

    local procedure LoadLastSet()
    var
        Field: Record "Field";
    begin
        GetFilteredField(Field);
        MatrixSetNr := Field.Count div 10;
        CurrPage.Update();
    end;

    local procedure OpenFieldsSelection()
    var
        FieldsLookup: Page "Fields Lookup";
        Field: Record "Field";
        Return: Action;
    begin
        GetFilteredField(Field);
        FieldsLookup.SetTableView(Field);
        FieldsLookup.LookupMode(true);
        Return := FieldsLookup.RunModal();
        if not (Return in [Action::OK, Action::LookupOK]) then
            exit;

        FieldsLookup.SetSelectionFilter(Field);
        Field.SetRange(IsPartOfPrimaryKey, false);
        if Field.FindSet() then
            repeat
                TempSelectedField := Field;
                if TempSelectedField.Insert() then;
            until Field.Next() = 0;

        LoadCaptions();
        CurrPage.Update(false);
    end;

    local procedure SetMatrixDataVisibility()
    begin
        MatrixDataVisibility1 := CaptionData[GetControlSetNr(1)] <> '';
        MatrixDataVisibility2 := CaptionData[GetControlSetNr(2)] <> '';
        MatrixDataVisibility3 := CaptionData[GetControlSetNr(3)] <> '';
        MatrixDataVisibility4 := CaptionData[GetControlSetNr(4)] <> '';
        MatrixDataVisibility5 := CaptionData[GetControlSetNr(5)] <> '';
        MatrixDataVisibility6 := CaptionData[GetControlSetNr(6)] <> '';
        MatrixDataVisibility7 := CaptionData[GetControlSetNr(8)] <> '';
        MatrixDataVisibility8 := CaptionData[GetControlSetNr(8)] <> '';
        MatrixDataVisibility9 := CaptionData[GetControlSetNr(9)] <> '';
        MatrixDataVisibility10 := CaptionData[GetControlSetNr(10)] <> '';
    end;

    local procedure GetTableName(): Text
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::TableData, TableID) then
            exit(AllObjWithCaption."Object Caption");
    end;

    local procedure OpenPageRecord()
    var
        RecRef: RecordRef;
        VariantRec: Variant;
        ConfigManagement: Codeunit "Config. Management";
        PageID: Integer;
        PageMetadata: Record "Page Metadata";
    begin
        GetRecRef(RecRef);
        VariantRec := RecRef;
        PageID := ConfigManagement.FindPage(TableID);
        if PageMetadata.Get(PageID) and (PageMetadata.CardPageID <> 0) then
            page.Runmodal(PageMetadata.CardPageID, VariantRec)
        else
            page.Runmodal(0, VariantRec);

        LoadValues();
    end;

    local procedure FieldDateLookup(iter: Integer; var Field: Record Field)
    var
        DateTimeDialog: Page "Date-Time Dialog";
        Date: date;
        DateTime: DateTime;
        TypeHelper: Codeunit "Type Helper";
        DotNet_CultureInfo: codeunit "DotNet_CultureInfo";
        Variant: Variant;
        Return: Action;
    begin
        case field.Type of
            field.Type::Date:
                begin
                    Variant := Date;
                    TypeHelper.Evaluate(Variant, MatrixData[iter], '', DotNet_CultureInfo.CurrentCultureName());
                    date := Variant;
                    DateTimeDialog.SetDate(Date);
                    Return := DateTimeDialog.RunModal();
                    if Return in [Action::LookupOK, Action::OK] then
                        MatrixData[iter] := format(DateTimeDialog.GetDate());
                end;
            field.Type::DateTime:
                begin
                    Variant := DateTime;
                    TypeHelper.Evaluate(Variant, MatrixData[iter], '', DotNet_CultureInfo.CurrentCultureName());
                    DateTime := Variant;
                    DateTimeDialog.SetDateTime(DateTime);
                    Return := DateTimeDialog.RunModal();
                    if Return in [Action::LookupOK, Action::OK] then
                        MatrixData[iter] := format(DateTimeDialog.GetDateTime());
                end;
        end;

        ChangeValues(iter);
    end;

    local procedure FieldBooleanLookup(iter: Integer)
    var
        Options: Label 'Yes,No';
        Return: Integer;
        Default: Integer;
    begin
        if EvaluateBoolean(iter) = true then
            Default := 1
        else
            Default := 2;

        Return := StrMenu(Options, Default);
        if Return = 0 then
            exit;

        MatrixData[iter] := Format(return = 1);
        ChangeValues(iter);
    end;

    local procedure EvaluateBoolean(var iter: Integer) TempBool: Boolean
    begin
        if MatrixData[iter] = '' then
            MatrixData[iter] := Format(false);

        Evaluate(TempBool, MatrixData[iter]);
    end;

    local procedure SelectTableKey()
    var
        Sortingkeys: Page "Sorting keys";
        Return: Action;
    begin
        if TempSelectedKey.Delete() then;

        Sortingkeys.SetTableNo(TableID, TempKeys);
        Sortingkeys.LookupMode := true;
        Return := Sortingkeys.RunModal();
        if not (Return in [Action::OK, Action::LookupOK]) then
            exit;

        Sortingkeys.GetTempKey(TempKeys);
        Sortingkeys.GetSelectedRec(TempSelectedKey);
        LoadRecords();
    end;

    local procedure SetKeyOnRecRef(var RecRef: RecordRef)
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        if TempSelectedKey.IsEmpty then
            exit;

        TempSelectedKey.FindFirst();
        TypeHelper.SortRecordRef(RecRef, TempSelectedKey."Key", not TempSelectedKey.Unique);
    end;

    local procedure ExportToExcel()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        Iter: Integer;
        Field: record Field;
        RecRef: RecordRef;
    begin
        RecRef.Open(TableID);
        for Iter := 1 to RecRef.FieldCount do
            ExcelBuffer.AddColumn(CaptionData[Iter], false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        if rec.FindSet() then
            repeat
                ExcelBuffer.NewRow();
                LoadValues();

                for iter := 1 to RecRef.FieldCount do begin
                    Field.get(TableID, GetFieldNo(Iter));
                    case field.Type of
                        field.type::Integer, field.type::Decimal:
                            ExcelBuffer.AddColumn(MatrixData[Iter], false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                        field.type::Date, field.type::DateTime:
                            ExcelBuffer.AddColumn(MatrixData[Iter], false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                        else
                            ExcelBuffer.AddColumn(MatrixData[Iter], false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
                    end;
                end;
            until Rec.Next() = 0;

        ExcelBuffer.CreateNewBook(GetTableName());
        ExcelBuffer.WriteSheet(GetTableName, COMPANYNAME, USERID);
        ExcelBuffer.CloseBook;
        ExcelBuffer.SetFriendlyFilename(GetTableName);
        ExcelBuffer.OpenExcel;

        if rec.FindFirst() then;
    end;

    procedure CountRec()
    var
        RecRef: RecordRef;
    begin
        PrepareRecRef(RecRef);
        RecordCount := RecRef.Count;
    end;

    local procedure DeleteAllRecords()
    var
        RecRef: RecordRef;
        ConfirmTxt: Label 'Do you want to delete all the filtered records?';
    begin
        if not confirm(ConfirmTxt) then
            exit;

        PrepareRecRef(RecRef);
        RecRef.DeleteAll(RunTriggers);
        ClearFilter();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGenericDatabaseWrite(Var RecRef: RecordRef; RunTriggers: Boolean; OperationType: Option Insert,Modify,Delete,Rename; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGenericDatabaseRename(Var RecRef: RecordRef; FieldCount: Integer; Var1: Variant; Var2: Variant; Var3: Variant; Var4: Variant; Var5: Variant; var IsHandled: Boolean)
    begin
    end;

    var
        CompanyName: Text;
        TableID: Integer;
        MatrixData: array[500] of Text;
        CaptionData: array[500] of Text;
        KeyMatrixData: array[10] of text;
        KeyCaptionData: array[10] of text;
        RecDictionary: Dictionary of [Integer, RecordId];
        FieldDictionary: Dictionary of [Integer, Integer];
        ValidateFields: Boolean;
        RunTriggers: Boolean;
        MatrixSetNr: Integer;
        RecordCount: Integer;
        KeyControlVisibility1: Boolean;
        KeyControlVisibility2: Boolean;
        KeyControlVisibility3: Boolean;
        KeyControlVisibility4: Boolean;
        KeyControlVisibility5: Boolean;
        MatrixDataVisibility1: Boolean;
        MatrixDataVisibility2: Boolean;
        MatrixDataVisibility3: Boolean;
        MatrixDataVisibility4: Boolean;
        MatrixDataVisibility5: Boolean;
        MatrixDataVisibility6: Boolean;
        MatrixDataVisibility7: Boolean;
        MatrixDataVisibility8: Boolean;
        MatrixDataVisibility9: Boolean;
        MatrixDataVisibility10: Boolean;
        TempTableFilter: Record "Table Filter" temporary;
        TableFiltersText: Text;
        TempSelectedField: record Field temporary;
        TempKeys: record "Key" temporary;
        TempSelectedKey: record "Key" temporary;
        OperationType: Option Insert,Modify,Delete,Rename;
}