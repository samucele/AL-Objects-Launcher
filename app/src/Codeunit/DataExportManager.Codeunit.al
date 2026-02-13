namespace SamueleCelebron.ObjectLauncher;

using System.IO;
using System.Reflection;

/// <summary>
/// Stateless codeunit responsible for exporting table data to Excel.
/// Receives the Table Data Manager by var to iterate records and read field metadata.
/// Uses its own local arrays to avoid mutating the page display during export.
/// </summary>
codeunit 50103 "Data Export Manager"
{
    /// <summary>
    /// Exports the currently loaded table data to an Excel workbook.
    /// Builds a header row from field captions, then iterates all loaded records
    /// writing each field value with the appropriate Excel cell type.
    /// Shows a progress dialog during export. Raises an error if no records are loaded.
    /// </summary>
    /// <param name="TableDataManager">The stateful Table Data Manager providing records and field metadata.</param>
    procedure ExportTableToExcel(var TableDataManager: Codeunit "Table Data Manager")
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        FieldRecord: Record Field;
        LocalCaptionArray: array[500] of Text;
        LocalKeyCaptionArray: array[10] of Text;
        LocalValueArray: array[500] of Text;
        LocalKeyValueArray: array[10] of Text;
        FieldTypeArray: array[500] of Integer;
        ProgressDialog: Dialog;
        ColumnIndex: Integer;
        FieldCount: Integer;
        FieldNumber: Integer;
        RowNumber: Integer;
        TotalRows: Integer;
        TableCaption: Text;
    begin
        TotalRows := TableDataManager.GetRecordCount();
        if TotalRows = 0 then
            Error(NoRecordsToExportErr);

        TableCaption := TableDataManager.GetTableCaption();

        if GuiAllowed then
            ProgressDialog.Open(ExportingRowsDialogLbl);

        // Load captions into local array
        TableDataManager.LoadFieldCaptions(LocalCaptionArray, LocalKeyCaptionArray);

        // Count the fields by iterating the caption array
        FieldCount := CountPopulatedFields(LocalCaptionArray);

        // Build header row
        BuildHeaderRow(ExcelBuffer, LocalCaptionArray, FieldCount);

        // Pre-cache cell type classification to avoid N+1 queries in the row loop
        // 1 = Number, 2 = Date, 3 = Text
        for ColumnIndex := 1 to FieldCount do begin
            FieldNumber := TableDataManager.GetFieldNumber(ColumnIndex);
            FieldRecord.SetLoadFields(Type);
            FieldRecord.Get(TableDataManager.GetTableNumber(), FieldNumber);
            case FieldRecord.Type of
                FieldRecord.Type::Integer, FieldRecord.Type::Decimal, FieldRecord.Type::BigInteger:
                    FieldTypeArray[ColumnIndex] := 1;
                FieldRecord.Type::Date, FieldRecord.Type::DateTime, FieldRecord.Type::Time:
                    FieldTypeArray[ColumnIndex] := 2;
                else
                    FieldTypeArray[ColumnIndex] := 3;
            end;
        end;

        // Build data rows
        for RowNumber := 1 to TotalRows do begin
            ExcelBuffer.NewRow();
            TableDataManager.LoadRecordValues(RowNumber, LocalValueArray, LocalKeyValueArray);

            BuildDataRow(ExcelBuffer, LocalValueArray, FieldCount, FieldTypeArray);

            if GuiAllowed then
                ProgressDialog.Update(1, Round(RowNumber / TotalRows * 10000, 1));
        end;

        if GuiAllowed then
            ProgressDialog.Close();

        // Create and open the Excel workbook
        ExcelBuffer.CreateNewBook(TableCaption);
        ExcelBuffer.WriteSheet(TableCaption, CompanyName, UserId);
        ExcelBuffer.CloseBook();
        ExcelBuffer.SetFriendlyFilename(TableCaption);
        ExcelBuffer.OpenExcel();
    end;

    /// <summary>
    /// Counts the number of populated field entries in the caption array.
    /// Iterates from index 1 until an empty entry is found or the maximum is reached.
    /// </summary>
    /// <param name="CaptionArray">The caption array to count.</param>
    /// <returns>The number of non-empty caption entries.</returns>
    local procedure CountPopulatedFields(var CaptionArray: array[500] of Text): Integer
    var
        MaxFieldCount: Integer;
        Index: Integer;
    begin
        MaxFieldCount := ArrayLen(CaptionArray);
        for Index := 1 to MaxFieldCount do
            if CaptionArray[Index] = '' then
                exit(Index - 1);

        exit(MaxFieldCount);
    end;

    /// <summary>
    /// Builds the header row in the Excel buffer using field captions.
    /// </summary>
    /// <param name="ExcelBuffer">The Excel buffer to write to.</param>
    /// <param name="CaptionArray">The caption array containing field captions.</param>
    /// <param name="FieldCount">The number of fields to include.</param>
    local procedure BuildHeaderRow(var ExcelBuffer: Record "Excel Buffer" temporary; var CaptionArray: array[500] of Text; FieldCount: Integer)
    var
        ColumnIndex: Integer;
    begin
        for ColumnIndex := 1 to FieldCount do
            ExcelBuffer.AddColumn(CaptionArray[ColumnIndex], false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
    end;

    /// <summary>
    /// Builds a data row in the Excel buffer, mapping each field value to the correct cell type.
    /// Numeric fields use Number cell type, date fields use Date cell type, all others use Text.
    /// </summary>
    /// <param name="ExcelBuffer">The Excel buffer to write to.</param>
    /// <param name="TableDataManager">The Table Data Manager for field number lookup.</param>
    /// <param name="ValueArray">The array of formatted field values for this row.</param>
    /// <param name="FieldCount">The number of fields to include.</param>
    local procedure BuildDataRow(var ExcelBuffer: Record "Excel Buffer" temporary; var ValueArray: array[500] of Text; FieldCount: Integer; CellTypeArray: array[500] of Integer)
    var
        ColumnIndex: Integer;
    begin
        for ColumnIndex := 1 to FieldCount do
            case CellTypeArray[ColumnIndex] of
                1: // Number
                    ExcelBuffer.AddColumn(ValueArray[ColumnIndex], false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
                2: // Date
                    ExcelBuffer.AddColumn(ValueArray[ColumnIndex], false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
                else // Text
                    ExcelBuffer.AddColumn(ValueArray[ColumnIndex], false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
            end;
    end;

    var
        NoRecordsToExportErr: Label 'There are no records to export. Load records before attempting to export to Excel.';
        ExportingRowsDialogLbl: Label 'Exporting to Excel... @1@@@@@@@@@@';
}
