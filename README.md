The [IfG Ministers Database](https://www.instituteforgovernment.org.uk/ministers-database) provides information on all ministers in UK governments since Margaret Thatcher became prime minister in 1979. The database provides information on ministers’ role, department, rank and dates in office.

You can look up individual ministers, specific ministerial roles, the entire government on a specific date or all those who left and entered government between two dates.

This repository contains the underlying data as well as related scripts.

# Database structure
![Database diagram of the IfG Ministers Database](IfG%20Ministers%20Database%20-%20v2.1.0%20(Current).png)

The database consists of the following tables:

## `appointment`
Links `person` and `post` records - one record per appointment.

`start_date` is always specified; `end_date` is `null` for ongoing appointments.

## `appointment_characteristics`
Each `appointment` timespan is split into one or more `appointment_characteristics` records.

The `appointment_characteristics` table records someone's `cabinet_status` - whether they were `Full cabinet`, `Attends Cabinet`, `Attends cabinet when ministerial responsibilities are on the agenda`, or `Non-cabinet` - as well as whether someone was doing a role in an acting capacity or was on leave from a role for a given time period.

`start_date` is always specified; `end_date` is `null` for ongoing appointments.

## `event`
Contains the dates of all general elections since 1979 and the day each prime minister completed their first ministerial line-up upon taking office.

## `organisation`
Contains one record for each organisation (generally a government department) at which a minister has been based.

`start_date` is always specified; `end_date` is `null` for ongoing appointments.

`short_name` is the department's initialism - note that these can be repeated.

## `organisation_link`
Links predecessor and successor organisations.

`type` is the IfG's determination of the link - one of `Merger`, `Demerger`, `Name change`, `Transfer of functions`.

Links have an associated date range. `link_start_date` is the date the change was announced. `link_end_date` is the final date that a minister moved from the predecessor organisation to the successor organisation as part of the change. `link_start_date` and `link_end_date` are always specified.

## `person`
Contains basic biographical details of people who have served as ministers.

Split into multiple records where someone's biographical details (name, gender) have changed.

`start_date` and `end_date` are only present where they are needed to indicate the start/end of a set of characteristics - `null` otherwise.

## `post`
Contains one record for each post that has existed at each organisation.

`rank_equivalence` is the IfG's determination of a post's rank - one of `PM`, `DPM`, `SoS`, `MoS`, `PUSS`, `Parl. lead`, `Parl.`.

## `post_relationship`
Links posts that are related to one another.

Relationships are IfG-derived and are principally based on post names, rather than a deeper analysis of ministerial responsibilities.

## `representation`
Records periods of parliamentary representation.

`start_date` is always specified; `end_date` is `null` for ongoing periods of representation.

## `representation_characteristics`
Each `representation` timespan is split into one or more `representation_characteristics` records.

`start_date` is always specified; `end_date` is `null` for ongoing periods of representation.

# Scripts
The `sql` directory contains scripts that power the IfG Ministers Database pages.

Subdirectories contains scripts relating to the following pages:
- `1_appointments_held_by_person`: [_Look up a minister_ page](https://www.instituteforgovernment.org.uk/ministers-database/look-minister)
- `2_persons_holding_appointment`: [_Look up a ministerial role_ page](https://www.instituteforgovernment.org.uk/ministers-database/look-ministerial-role)
- `3_appointments_at_date`: [_View entire government_ page](https://www.instituteforgovernment.org.uk/ministers-database/view-entire-government)
- `4_appointments_exits_between_dates`: [_View ministerial appointments and exits_ page](https://www.instituteforgovernment.org.uk/ministers-database/view-ministerial-appointments-and-exits)

In each case, the scripts most likely to be of use are those which populate the data tables on each page. Each is available in two forms: one which doesn't merge appointments spanning [departmental restructures](https://www.instituteforgovernment.org.uk/ministers-database/how-use-database#departmental-restructures) (`...unmerged.sql`) and one that does (`...merged.sql`). These scripts are:
- [`1_table_data_unmerged.sql`](https://github.com/instituteforgov/ifg-ministers-database-public/blob/main/sql/1_appointments_held_by_person/1_table_data_unmerged.sql), [`1_table_data_merged.sql`](https://github.com/instituteforgov/ifg-ministers-database-public/blob/main/sql/1_appointments_held_by_person/1_table_data_merged.sql),
- [`2_table_data_unmerged.sql`](https://github.com/instituteforgov/ifg-ministers-database-public/blob/main/sql/2_persons_holding_appointment/2_table_data_unmerged.sql), [`2_table_data_merged.sql`](https://github.com/instituteforgov/ifg-ministers-database-public/blob/main/sql/2_persons_holding_appointment/2_table_data_merged.sql),
- [`3_table_data_unmerged.sql`](https://github.com/instituteforgov/ifg-ministers-database-public/blob/main/sql/3_appointments_at_date/3_table_data_unmerged.sql), [`3_table_data_merged.sql`](https://github.com/instituteforgov/ifg-ministers-database-public/blob/main/sql/3_appointments_at_date/3_table_data_merged.sql),
- [`4_table_data_unmerged.sql`](https://github.com/instituteforgov/ifg-ministers-database-public/blob/main/sql/4_appointments_exits_between_dates/4_table_data_unmerged.sql), [`4_table_data_merged.sql`](https://github.com/instituteforgov/ifg-ministers-database-public/blob/main/sql/4_appointments_exits_between_dates/4_table_data_merged.sql),

# Further details
Further details on sourcing, limitations and judgements made in creating the database can be found on the IfG Ministers Database [_About the database_](https://www.instituteforgovernment.org.uk/ministers-database/about-database) and [_How to use the database_](https://www.instituteforgovernment.org.uk/ministers-database/how-use-database#departmental-restructures) pages.

# Enquiries
If you spot any errors in or problems with the database, or have any questions or suggestions, please contact us at [ministers.database@instituteforgovernment.org.uk](mailto:ministers.database@instituteforgovernment.org.uk).

For any media queries about the database, please get in touch with our press office: [press@instituteforgovernment.org.uk](mailto:press@instituteforgovernment.org.uk).
