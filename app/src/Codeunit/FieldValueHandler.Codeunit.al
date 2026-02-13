namespace SamueleCelebron.ObjectLauncher;

using System.Reflection;
using System.Globalization;
using System.Text;
using System.DateTime;

/// <summary>
/// Stateless codeunit responsible for all field-level operations: type-aware value parsing,
/// field editability validation, and lookup dispatch. Receives TableDataManager by var for context.
/// Calls RecordWriter for actual database mutations.
/// </summary>
codeunit 50101 "Field Value Handler"
{
    #region Value Writing

    /// <summary>
    /// Central orchestrator for writing a field value. Replaces the original ChangeValues procedure.
    /// Validates the field is editable, parses the new value by field type, applies it via
    /// Validate or direct Value assignment, then routes to the appropriate write operation
    /// (modify, insert, or rename). Refreshes the display arrays afterward.
    /// </summary>
    /// <param name="TableDataManager">The stateful Table Data Manager for context access.</param>
    /// <param name="RowNumber">The row number of the record being edited.</param>
    /// <param name="ColumnIndex">The column index identifying the field.</param>
    /// <param name="NewValueText">The new value as text entered by the user.</param>
    /// <param name="ValueArray">The data value array to refresh after the write.</param>
    /// <param name="KeyValueArray">The key value array to refresh after the write.</param>
    procedure WriteFieldValue(var TableDataManager: Codeunit "Table Data Manager"; RowNumber: Integer; ColumnIndex: Integer; NewValueText: Text; var ValueArray: array[500] of Text; var KeyValueArray: array[10] of Text)
    var
        FieldRecord: Record Field;
        RecordWriter: Codeunit "Record Writer";
        DotNetCultureInfo: Codeunit DotNet_CultureInfo;
        TypeHelper: Codeunit "Type Helper";
        RecordReference: RecordRef;
        FieldReference: FieldRef;
        OldValue: Variant;
        TypedValue: Variant;
        RecordExists: Boolean;
        TableNumber: Integer;
        FieldNumber: Integer;
    begin
        TableNumber := TableDataManager.GetTableNumber();
        FieldNumber := TableDataManager.GetFieldNumber(ColumnIndex);

        ValidateFieldEditable(TableNumber, FieldNumber);

        RecordExists := TableDataManager.GetRecordReference(RowNumber, RecordReference);
        FieldReference := RecordReference.Field(FieldNumber);
        FieldRecord.SetLoadFields(Type, IsPartOfPrimaryKey);
        FieldRecord.Get(TableNumber, FieldNumber);

        TypedValue := FieldReference.Value;
        OldValue := TypedValue;

        case FieldRecord.Type of
            FieldRecord.Type::Code, FieldRecord.Type::Text:
                TypedValue := NewValueText;
            FieldRecord.Type::Option:
                TypedValue := TypeHelper.GetOptionNo(NewValueText, FieldReference.OptionCaption);
            FieldRecord.Type::Boolean:
                TypedValue := EvaluateBooleanText(NewValueText);
            else
                TypeHelper.Evaluate(TypedValue, NewValueText, '', DotNetCultureInfo.CurrentCultureName());
        end;

        if TableDataManager.GetValidateFields() then
            FieldReference.Validate(TypedValue)
        else
            FieldReference.Value(TypedValue);

        if RecordExists then begin
            if FieldRecord.IsPartOfPrimaryKey then
                RecordWriter.RenameRecord(
                    RecordReference, FieldReference, OldValue,
                    TableNumber, TableDataManager.GetReadOnlyMode(),
                    TableDataManager, RowNumber)
            else
                RecordWriter.ModifyRecord(
                    RecordReference,
                    TableDataManager.GetRunTriggers(),
                    TableDataManager.GetReadOnlyMode());
        end else begin
            RecordWriter.InsertRecord(
                RecordReference,
                TableDataManager.GetRunTriggers(),
                TableDataManager.GetReadOnlyMode());
            TableDataManager.AddRecordId(RowNumber, RecordReference.RecordId);
            TableDataManager.CountRecords();
        end;

        TableDataManager.LoadRecordValues(RowNumber, ValueArray, KeyValueArray);
    end;

    #endregion

    #region Lookups

    /// <summary>
    /// Dispatches to the appropriate type-specific lookup based on the field type.
    /// Supports Option, Date/DateTime, Boolean, and table relation lookups.
    /// </summary>
    /// <param name="TableDataManager">The stateful Table Data Manager for context access.</param>
    /// <param name="RowNumber">The row number of the record being looked up.</param>
    /// <param name="ColumnIndex">The column index identifying the field.</param>
    /// <param name="ValueArray">The data value array to refresh after selection.</param>
    /// <param name="KeyValueArray">The key value array to refresh after selection.</param>
    procedure PerformFieldLookup(var TableDataManager: Codeunit "Table Data Manager"; RowNumber: Integer; ColumnIndex: Integer; var ValueArray: array[500] of Text; var KeyValueArray: array[10] of Text)
    var
        FieldRecord: Record Field;
        TableRelationsMetadata: Record "Table Relations Metadata";
        TableNumber: Integer;
        FieldNumber: Integer;
    begin
        TableNumber := TableDataManager.GetTableNumber();
        FieldNumber := TableDataManager.GetFieldNumber(ColumnIndex);
        FieldRecord.SetLoadFields(Type);
        FieldRecord.Get(TableNumber, FieldNumber);

        case true of
            (FieldRecord.Type = FieldRecord.Type::Option):
                PerformOptionLookup(TableDataManager, RowNumber, ColumnIndex, ValueArray, KeyValueArray);
            (FieldRecord.Type in [FieldRecord.Type::Date, FieldRecord.Type::DateTime]):
                PerformDateLookup(TableDataManager, RowNumber, ColumnIndex, FieldRecord, ValueArray, KeyValueArray);
            (FieldRecord.Type = FieldRecord.Type::Boolean):
                PerformBooleanLookup(TableDataManager, RowNumber, ColumnIndex, ValueArray, KeyValueArray);
            HasTableRelation(TableNumber, FieldNumber, TableRelationsMetadata):
                PerformRelationLookup(TableDataManager, RowNumber, ColumnIndex, TableRelationsMetadata, ValueArray, KeyValueArray);
        end;
    end;

    /// <summary>
    /// Performs a lookup for an Option field by presenting a StrMenu with option values.
    /// Writes the selected value back to the field.
    /// </summary>
    /// <param name="TableDataManager">The stateful Table Data Manager for context access.</param>
    /// <param name="RowNumber">The row number of the record.</param>
    /// <param name="ColumnIndex">The column index of the Option field.</param>
    /// <param name="ValueArray">The data value array to refresh and read current value from.</param>
    /// <param name="KeyValueArray">The key value array to refresh after selection.</param>
    procedure PerformOptionLookup(var TableDataManager: Codeunit "Table Data Manager"; RowNumber: Integer; ColumnIndex: Integer; var ValueArray: array[500] of Text; var KeyValueArray: array[10] of Text)
    var
        TypeHelper: Codeunit "Type Helper";
        RecordReference: RecordRef;
        FieldReference: FieldRef;
        DefaultNumber: Integer;
        SelectedOption: Integer;
    begin
        TableDataManager.GetRecordReference(RowNumber, RecordReference);
        FieldReference := RecordReference.Field(TableDataManager.GetFieldNumber(ColumnIndex));

        DefaultNumber := TypeHelper.GetOptionNo(ValueArray[ColumnIndex], FieldReference.OptionCaption) + 1;
        SelectedOption := StrMenu(FieldReference.OptionCaption, DefaultNumber);
        if SelectedOption = 0 then
            exit;

        ValueArray[ColumnIndex] := SelectStr(SelectedOption, FieldReference.OptionCaption);
        WriteFieldValue(TableDataManager, RowNumber, ColumnIndex, ValueArray[ColumnIndex], ValueArray, KeyValueArray);
    end;

    /// <summary>
    /// Performs a lookup for a field that has a table relation.
    /// Opens the related table, lets the user pick a record, and writes the value back.
    /// </summary>
    /// <param name="TableDataManager">The stateful Table Data Manager for context access.</param>
    /// <param name="RowNumber">The row number of the record.</param>
    /// <param name="ColumnIndex">The column index of the field with a relation.</param>
    /// <param name="TableRelationsMetadata">The table relation metadata for the field.</param>
    /// <param name="ValueArray">The data value array to refresh after selection.</param>
    /// <param name="KeyValueArray">The key value array to refresh after selection.</param>
    procedure PerformRelationLookup(var TableDataManager: Codeunit "Table Data Manager"; RowNumber: Integer; ColumnIndex: Integer; var TableRelationsMetadata: Record "Table Relations Metadata"; var ValueArray: array[500] of Text; var KeyValueArray: array[10] of Text)
    var
        RecordReference: RecordRef;
        RelationRecordReference: RecordRef;
        RelationFieldReference: FieldRef;
        UserAction: Action;
        VariantRecord: Variant;
    begin
        TableDataManager.GetRecordReference(RowNumber, RecordReference);
        ResolveRelationCondition(TableRelationsMetadata, RecordReference, TableDataManager.GetTableNumber());

        RelationRecordReference.Open(TableRelationsMetadata."Related Table ID", false, TableDataManager.GetCompanyName());
        RelationFieldReference := RelationRecordReference.Field(TableRelationsMetadata."Related Field No.");
        VariantRecord := RelationRecordReference;

        UserAction := Page.RunModal(0, VariantRecord);
        if not (UserAction in [Action::OK, Action::LookupOK]) then
            exit;

        RelationRecordReference := VariantRecord;
        RelationFieldReference := RelationRecordReference.Field(TableRelationsMetadata."Related Field No.");
        ValueArray[ColumnIndex] := Format(RelationFieldReference.Value);
        WriteFieldValue(TableDataManager, RowNumber, ColumnIndex, ValueArray[ColumnIndex], ValueArray, KeyValueArray);
    end;

    /// <summary>
    /// Performs a lookup for Date and DateTime fields using the Date-Time Dialog page.
    /// Opens the dialog with the current value pre-populated and writes the selection back.
    /// </summary>
    /// <param name="TableDataManager">The stateful Table Data Manager for context access.</param>
    /// <param name="RowNumber">The row number of the record.</param>
    /// <param name="ColumnIndex">The column index of the Date/DateTime field.</param>
    /// <param name="FieldRecord">The Field record with type information.</param>
    /// <param name="ValueArray">The data value array to refresh after selection.</param>
    /// <param name="KeyValueArray">The key value array to refresh after selection.</param>
    procedure PerformDateLookup(var TableDataManager: Codeunit "Table Data Manager"; RowNumber: Integer; ColumnIndex: Integer; var FieldRecord: Record Field; var ValueArray: array[500] of Text; var KeyValueArray: array[10] of Text)
    var
        DotNetCultureInfo: Codeunit DotNet_CultureInfo;
        TypeHelper: Codeunit "Type Helper";
        DateTimeDialog: Page "Date-Time Dialog";
        UserAction: Action;
        DateValue: Date;
        DateTimeValue: DateTime;
        VariantValue: Variant;
    begin
        case FieldRecord.Type of
            FieldRecord.Type::Date:
                begin
                    VariantValue := DateValue;
                    TypeHelper.Evaluate(VariantValue, ValueArray[ColumnIndex], '', DotNetCultureInfo.CurrentCultureName());
                    DateValue := VariantValue;
                    DateTimeDialog.SetDate(DateValue);
                    UserAction := DateTimeDialog.RunModal();
                    if UserAction in [Action::LookupOK, Action::OK] then
                        ValueArray[ColumnIndex] := Format(DateTimeDialog.GetDate());
                end;
            FieldRecord.Type::DateTime:
                begin
                    VariantValue := DateTimeValue;
                    TypeHelper.Evaluate(VariantValue, ValueArray[ColumnIndex], '', DotNetCultureInfo.CurrentCultureName());
                    DateTimeValue := VariantValue;
                    DateTimeDialog.SetDateTime(DateTimeValue);
                    UserAction := DateTimeDialog.RunModal();
                    if UserAction in [Action::LookupOK, Action::OK] then
                        ValueArray[ColumnIndex] := Format(DateTimeDialog.GetDateTime());
                end;
        end;

        WriteFieldValue(TableDataManager, RowNumber, ColumnIndex, ValueArray[ColumnIndex], ValueArray, KeyValueArray);
    end;

    /// <summary>
    /// Performs a lookup for Boolean fields by presenting a Yes/No StrMenu.
    /// Writes the selected value back to the field.
    /// </summary>
    /// <param name="TableDataManager">The stateful Table Data Manager for context access.</param>
    /// <param name="RowNumber">The row number of the record.</param>
    /// <param name="ColumnIndex">The column index of the Boolean field.</param>
    /// <param name="ValueArray">The data value array to refresh after selection.</param>
    /// <param name="KeyValueArray">The key value array to refresh after selection.</param>
    procedure PerformBooleanLookup(var TableDataManager: Codeunit "Table Data Manager"; RowNumber: Integer; ColumnIndex: Integer; var ValueArray: array[500] of Text; var KeyValueArray: array[10] of Text)
    var
        DefaultNumber: Integer;
        SelectedOption: Integer;
    begin
        if EvaluateBooleanText(ValueArray[ColumnIndex]) then
            DefaultNumber := 1
        else
            DefaultNumber := 2;

        SelectedOption := StrMenu(BooleanOptionsLbl, DefaultNumber);
        if SelectedOption = 0 then
            exit;

        ValueArray[ColumnIndex] := Format(SelectedOption = 1);
        WriteFieldValue(TableDataManager, RowNumber, ColumnIndex, ValueArray[ColumnIndex], ValueArray, KeyValueArray);
    end;

    #endregion

    #region Validation

    /// <summary>
    /// Validates that a field can be edited. Raises an error if the field is a FlowField
    /// (which cannot be written to directly) or if the field is disabled.
    /// </summary>
    /// <param name="TableNumber">The table number containing the field.</param>
    /// <param name="FieldNumber">The field number to validate.</param>
    procedure ValidateFieldEditable(TableNumber: Integer; FieldNumber: Integer)
    var
        FieldRecord: Record Field;
    begin
        FieldRecord.SetLoadFields(Class, Enabled, "Field Caption");
        FieldRecord.Get(TableNumber, FieldNumber);

        if FieldRecord.Class <> FieldRecord.Class::Normal then
            Error(FieldNotEditableFlowFieldErr, FieldRecord."Field Caption");

        if not FieldRecord.Enabled then
            Error(FieldNotEditableDisabledErr, FieldRecord."Field Caption");
    end;

    #endregion

    #region Helpers

    /// <summary>
    /// Converts a text representation to a Boolean value.
    /// Treats empty string as false. Uses AL's built-in Evaluate for conversion.
    /// </summary>
    /// <param name="ValueText">The text to convert (e.g. "Yes", "No", "true", "false", "").</param>
    /// <returns>The Boolean result of the evaluation.</returns>
    procedure EvaluateBooleanText(ValueText: Text): Boolean
    var
        BooleanResult: Boolean;
    begin
        if ValueText = '' then
            exit(false);

        Evaluate(BooleanResult, ValueText);
        exit(BooleanResult);
    end;

    /// <summary>
    /// Checks whether a field has a table relation defined in the Table Relations Metadata.
    /// Positions the metadata record on the first matching relation if found.
    /// </summary>
    /// <param name="TableNumber">The table number to check.</param>
    /// <param name="FieldNumber">The field number to check.</param>
    /// <param name="TableRelationsMetadata">Returns the positioned metadata record if a relation exists.</param>
    /// <returns>True if the field has a table relation.</returns>
    procedure HasTableRelation(TableNumber: Integer; FieldNumber: Integer; var TableRelationsMetadata: Record "Table Relations Metadata"): Boolean
    begin
        TableRelationsMetadata.SetRange("Table ID", TableNumber);
        TableRelationsMetadata.SetRange("Field No.", FieldNumber);
        TableRelationsMetadata.SetFilter("Related Table ID", '<>%1', 0);
        exit(TableRelationsMetadata.FindFirst());
    end;

    /// <summary>
    /// Resolves conditional table relations to find the correct related table.
    /// When multiple relations exist for a field, evaluates the condition fields against
    /// the current record values to select the matching relation.
    /// </summary>
    /// <param name="TableRelationsMetadata">The table relations metadata to resolve. Positioned on the correct record on exit.</param>
    /// <param name="RecordReference">The current record used to evaluate conditions.</param>
    /// <param name="TableNumber">The table number for field lookups.</param>
    procedure ResolveRelationCondition(var TableRelationsMetadata: Record "Table Relations Metadata"; var RecordReference: RecordRef; TableNumber: Integer)
    var
        FieldRecord: Record Field;
        TypeHelper: Codeunit "Type Helper";
        ConditionFieldReference: FieldRef;
        ConditionFieldValue: Text;
    begin
        if TableRelationsMetadata.Count = 1 then
            exit;

        repeat
            FieldRecord.SetLoadFields(Type);
            FieldRecord.Get(TableNumber, TableRelationsMetadata."Condition Field No.");
            ConditionFieldReference := RecordReference.Field(TableRelationsMetadata."Condition Field No.");
            ConditionFieldValue := Format(ConditionFieldReference.Value);

            if FieldRecord.Type = FieldRecord.Type::Option then
                ConditionFieldValue := Format(TypeHelper.GetOptionNo(ConditionFieldValue, ConditionFieldReference.OptionMembers));

            case TableRelationsMetadata."Condition Type" of
                TableRelationsMetadata."Condition Type"::CONST:
                    if ConditionFieldValue = TableRelationsMetadata."Condition Value" then
                        exit;
            end;
        until TableRelationsMetadata.Next() = 0;
    end;

    #endregion

    var
        FieldNotEditableFlowFieldErr: Label 'Field "%1" is a FlowField and cannot be edited directly.', Comment = '%1 = Field caption';
        FieldNotEditableDisabledErr: Label 'Field "%1" is disabled and cannot be edited.', Comment = '%1 = Field caption';
        BooleanOptionsLbl: Label 'Yes,No';
}
