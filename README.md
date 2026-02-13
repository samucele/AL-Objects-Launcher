<p align="center">
  <img src="Logo/Logo.png" alt="AL Objects Launcher" width="128">
</p>

<h1 align="center">AL Objects Launcher</h1>

<p align="center">
  A developer toolkit for Business Central — quickly find and run any AL object, and edit table data on the fly.
</p>

<p align="center">
  <a href="#installation">Installation</a> &middot;
  <a href="#features">Features</a> &middot;
  <a href="#security">Security</a> &middot;
  <a href="LICENSE">License</a>
</p>

---

## Why?

Working in Business Central, you often need to look up an object, run a page, or peek at table data. Normally that means navigating menus, writing temporary code, or switching tools.

**AL Objects Launcher** gives you a single search page to find and run any installed AL object, plus a built-in table editor that lets you view and modify data in any table — no extra setup required.

## Features

### Object Launcher

Search across every installed extension and jump straight to any Table, Page, Report, or Codeunit. Filter by type, name, or extension, and launch it with one click.

### Table Data Editor

Open any table by number and work with its data directly:

- **Read & write** — Insert, modify, delete, and rename records
- **Dynamic columns** — Displays up to 500 fields with column set navigation
- **Smart editing** — Type-aware input with validation and lookups for Options, Booleans, Dates, and Relations
- **Cross-company** — Switch company context without leaving the page
- **Excel export** — Export with correct cell types (numbers, dates, text)
- **Safety first** — Sensitive tables (ledger entries, posted documents) trigger a confirmation before loading
- **Read-only mode** — Toggle read-only when you just need to browse

### Extensibility

The extension publishes integration events before every database operation, so you can hook in custom validation, logging, or audit trail logic.

## Installation

1. Clone this repository
2. Open the `app/` folder in VS Code with the AL Language extension
3. Download symbols and publish to your Business Central environment

> Requires Business Central runtime 15.0+ and application 26.0+.

## Security

The Table Data Editor needs broad table permissions to work as a generic editor. Access is controlled through the **AL Objects Launcher** permission set — assign it only to developers and administrators.

## License

[MIT](LICENSE)

## Author

**Samuele Celebron** — [GitHub](https://github.com/samucele)
