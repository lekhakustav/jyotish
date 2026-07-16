# Normalized facts

Normalized files use the headers in `marketing/templates/` and retain `source_export_id` lineage.
Partition growing facts by `YYYY-MM.csv`. Derived rates are calculated later from count and money
fields; do not hand-enter rates into normalized source facts.

Organic post rows are cumulative snapshots. Paid delivery rows are daily flows. They are not
interchangeable.
