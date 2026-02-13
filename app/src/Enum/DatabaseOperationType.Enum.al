namespace SamueleCelebron.ObjectLauncher;

/// <summary>
/// Specifies the type of database operation being performed.
/// Used by integration events on the Record Writer codeunit
/// to communicate the intended operation to subscribers.
/// </summary>
enum 50100 "Database Operation Type"
{
    Extensible = false;

    value(0; Insert)
    {
        Caption = 'Insert';
    }
    value(1; Modify)
    {
        Caption = 'Modify';
    }
    value(2; Delete)
    {
        Caption = 'Delete';
    }
    value(3; Rename)
    {
        Caption = 'Rename';
    }
}
