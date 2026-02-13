# AL Objects Launcher

A developer utility extension for Microsoft Dynamics 365 Business Central that provides a searchable launcher for all installed AL objects and a generic table data editor with full CRUD support.

## Features

### AL Objects Launcher (Page 50100)
- Browse all installed AL objects (Tables, Pages, Reports, Codeunits) across all extensions
- Filter by object type, name, or source extension
- Launch any object directly from the list
- Open the Table Data Editor for any table with one click

### Table Data Editor (Page 50102)
- Open **any** table by number with full read/write access
- Dynamic column display (up to 500 fields) with column set navigation
- Primary key fields displayed in a fixed header section
- Type-aware field editing with validation and lookups (Option, Boolean, Date, Relation)
- Record insert, modify, delete, and primary key rename support
- Cross-company data access
- Excel export with correct cell types (Number, Date, Text)
- Custom filtering, field selection, and key sorting
- Read-only mode toggle and trigger execution control
- Sensitive table detection with confirmation dialogs for posted/ledger tables

## Architecture

The extension follows a multi-codeunit architecture with clear separation of concerns:

| Object | ID | Purpose |
|---|---|---|
| AL Objects Launcher | 50100 | Page - Searchable object browser |
| Sorting Keys | 50101 | Page - Key selection for Table Data Editor |
| Table Data Editor | 50102 | Page - Generic table data editor UI |
| Database Operation Type | 50100 | Enum - Insert/Modify/Delete/Rename |
| Table Data Manager | 50100 | Codeunit - Record loading, field metadata, navigation |
| Field Value Handler | 50101 | Codeunit - Type-aware parsing, validation, lookups |
| Record Writer | 50102 | Codeunit - Database mutations with integration events |
| Data Export Manager | 50103 | Codeunit - Excel export with field type caching |
| AL Objects Launcher | 50100 | PermissionSet - Execute permissions for all objects |

### Extensibility

The `Record Writer` codeunit publishes integration events before every database operation:
- `OnBeforeGenericDatabaseWrite` - Fired before Insert, Modify, or Delete
- `OnBeforeGenericDatabaseRename` - Fired before record rename

Subscribe to these events to add custom validation, logging, or audit trail logic.

## Requirements

- Business Central runtime 15.0+
- Application version 26.0.0.0+
- Target: Cloud

## Installation

1. Clone this repository
2. Open the `app/` folder in VS Code with the AL Language extension
3. Download symbols and publish to your Business Central environment

## Project Structure

```
AL-Objects-Launcher/
  app/                          # Main extension
    app.json                    # Extension manifest (v2.0.0)
    src/
      Codeunit/
        DataExportManager.Codeunit.al
        FieldValueHandler.Codeunit.al
        RecordWriter.Codeunit.al
        TableDataManager.Codeunit.al
      Enum/
        DatabaseOperationType.Enum.al
      Page/
        ALObjectsLauncher.Page.al
        SortingKeys.Page.al
        TableDataEditor.Page.al
      Permission/
        ALObjectsLauncher.PermissionSet.al
  test/                         # Test extension (separate app)
    app.json
  Logo/
    Logo.png
```

## Security Notes

The Table Data Editor requires broad table permissions to function as a generic data editor. The page declares RIMD permissions for common posted/ledger tables. Access should be restricted to developers and administrators through the `AL Objects Launcher` permission set.

Sensitive tables (ledger entries, registers, posted documents) are detected automatically and trigger a confirmation dialog before loading.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

**Samuele Celebron** - [GitHub](https://github.com/samucele)
