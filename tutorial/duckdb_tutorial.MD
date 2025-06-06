# Using DuckDB to explore the IfG Ministers Database

## 🦆 DuckDB
[DuckDB](https://duckdb.org/) is a simple, open source database management system. It can be run easily on macOS, Windows and Linux.

For our purposes, a browser-based version, making use of WebAssembly, is also available at https://shell.duckdb.org/. Files in various formats, including [CSV, JSON and Parquet](https://duckdb.org/docs/data/data_sources), can be read in and queried as if they form a database.

Why is that useful? It allows us to use the powerful querying of SQL on any data files we throw at it, without *actually* needing to load them into a database. (DuckDB can also be used to read in certain database files - but at the time of writing the browser-based version doesn't work with all of these formats.)

SQL ("sequel", or "S-Q-L" - tomato/tomato) is the most commonly used language for querying databases. It's easy to pick up, and is efficient at reading and joining large volumes of data.

## IfG Ministers Database
The IfG Ministers Database is a resource developed by the [Institute for Government](https://instituteforgovernment.org.uk/) that provides information on all UK government ministers since Margaret Thatcher became prime minister in 1979. The database provides information on ministers’ role, department, rank and dates in office. It can be used to answer questions like:
- Who have been the longest serving ministers since 1979?
- What is the gender balance of Cabinet like, and how has it changed over time?
- How long do ministers stay in post? (A: [Not long enough](https://www.thetimes.com/article/ministers-have-same-job-security-as-football-managers-0zqcdj3pb))

<p align="center">
<img src="ministers-have-same-job-security-as-football-managers.png" alt="A screenshot of an article from The Times headlined 'Ministers have same job security as football managers', based on research carried out using the IfG Ministers Database" width="600"/>
</p>
<p align="center">
<em>A previous finding from analysis based on the IfG Ministers Database</em>
</p>

The database can be explored via a [web interface](https://www.instituteforgovernment.org.uk/ministers-database). For those with technical skills, we also  [publish the database on GitHub](https://github.com/instituteforgov/ifg-ministers-database-public/) under a Creative Commons by-attribution licence, both in SQLite form and CSV form. At the time of writing, the browser-based version of DuckDB doesn't work with SQLite files, so for the purposes of this tutorial we'll work with the CSV files.

In the `data` folder of the GitHub repo you should see multiple CSV files - one for each table in the database. The database consists of 11 tables, but in this this tutorial we'll work with four of them:
- `person`: Basic biographical details of everyone who has been a minister since 1979
- `post`: All posts in existence since 1979
- `organisation`: Organisations at which posts are based
- `appointment`: Links `person` records to `post` records

## Tutorial
### Reading the data in
1. Open https://shell.duckdb.org/ in a browser.
1. Files can be read in to DuckDB with minimal effort, and that's the first thing we need to do.

    Paste the following into the DuckDB Shell, then hit Enter:

    ```sql
    create table appointment as select * from 'https://raw.githubusercontent.com/instituteforgov/ifg-ministers-database-public/refs/heads/main/data/appointment.csv';
    create table organisation as select * from 'https://raw.githubusercontent.com/instituteforgov/ifg-ministers-database-public/refs/heads/main/data/organisation.csv';
    create table person as select * from 'https://raw.githubusercontent.com/instituteforgov/ifg-ministers-database-public/refs/heads/main/data/person.csv';
    create table post as select * from 'https://raw.githubusercontent.com/instituteforgov/ifg-ministers-database-public/refs/heads/main/data/post.csv';
    ```
    ___
    #### ✍ A note on formatting queries
    Unlike some languages (e.g. Python), SQL takes a relaxed approach to the formatting of queries - there aren't strict rules on things like the spacing used in queries.
    
    SQL queries can be written on a single line, though it's often helpful to split them onto multiple lines with some indentation, for readability.

    All statements in DuckDB need to end with a semi-colon - this lets DuckDB know where the statement ends.

    You might also find that it's easier to prepare your queries in a text editor and paste them into the DuckDB shell - it can be a little fiddly making edits to a query directly in the browser interface.
    ___

### Initial queries
1. Let's take a look at the `person` table. To do this, run the following statement:

    ```sql
    select *
    from person
    limit 10;
    ```

    SQL statements often look not dissimilar to English. This particular statement returns all columns (`select *`) from the top 10 rows (`limit 10`) of the `person` table.[^1]

    This should yield a table of results from the `person` table. Key columns to point out are:
    - `id`: An identifier tied to a unique individual, which we'll use for joining together records across tables
    - `name`: The name by which an individual was known for a given period in time. (For the purposes of this tutorial, we don't need to worry too much about the other name columns in the data)
    - `short_name`: The individual's last name or, in the case of some peers, the place mentioned in their title (e.g. Snowdon for the Earl of Snowdon)
    - `gender`: The individual's gender[^2]
    - `start_date` and `end_date`: The date when an individual started and ended being known by a given name. These values are only populated where an individual has changed name - while they look blank in other cases, they in fact contain `NULL`, which is how columns with no value are recorded in SQL.

    **Challenge**: Go ahead and write a statement that selects all columns from the top 20 rows of the `post` table. (Don't forget the semi-colon at the end.) We'll come back to what all the columns mean shortly.

    If you have some experience using SQL you might want to skip ahead at this stage to the _Joins_ section.

1. Often we only want to return certain columns from a given table. To do this, we can list the columns we're interested in in the `select` statement, separated by commas.

    Try running the following and seeing what the effect is:

    ```sql
    select
        id,
        name,
        gender,
        short_name,
        start_date,
        end_date 
    from person
    limit 10;
    ```

    We often want to order our results - the following will return the top 10 results ordered by `short_name`:

    ```sql
    select
        id,
        name,
        gender,
        short_name,
        start_date,
        end_date 
    from person
    order by
        short_name
    limit 10;
    ```

    By default, ascending ordering is applied. We could add `desc` after the name of the column we're ordering things by if we wanted to put things in descending order.

    **Challenge**: Go ahead and write a statement that selects all rows and all columns from the `organisation` table, ordering that table by the `name` columns.

1. Another useful SQL keyword to know about is `distinct`. This can be used to return distinct (different) values. 

    Try running the following:

    ```sql
    select distinct
        rank_equivalence
    from post;
    ```

    This returns all `rank_equivalence` values in the `post` table. `rank_equivalence` is an IfG-derived categorisation which attempts to classify posts with others of similar seniority. The values are as follows:
    - **PM**: Prime minister
    - **DPM**: Deputy prime minister (or first secretary of state)
    - **SoS**: Secretary of state - generally the minister running a government department
    - **MoS**: Minister of state - a more junior minister
    - **PUSS**: Parliamentary under-secretary of state - the most junior rank of minister
    - **Parl. lead.**: A parliamentary leadership role, like chief whip or leader of the House of Commons
    - **Parl.**: Another parliamentary role, such as a junior whip

    [You can find further explanation of these ranks here](https://www.instituteforgovernment.org.uk/ministers-database/how-use-database) - see the description under Rank.

1. Another important SQL keyword is `where`. Adding a `where` clause allows you to filter the results returned.

    For example, to find all women who've been ministers since 1979 you can use the following:

    ```sql
    select *
    from person
    where
        gender = 'F';
    ```

    (Note that things are case-sensitive - so you need to use a capital 'F'.)

    It's often useful to look for partial matches. You can do this using the `like` and `ilike` operators - using '`%`' as a wildcard replacing any number of characters. Try running the following example to see the effect (`ilike` carries out case-insensitive matching - we'll use that in this tutorial, to make sure we're not losing any results due to differences in capitalisation):

    ```sql
    select *
    from person
    where
        name ilike 'John%';
    ```

    You can apply multiple `where` clauses by separating them with `and` keywords. The following returns all ministers who have a gender of 'F' and whose name starts with 'Baroness'.

    ```sql
    select *
    from person
    where
        gender = 'F' and
        name ilike 'Baroness%';
    ```

    **Challenge**: Can you write a similar query to return all male ministers whose `short_name` ends with 'Smith' (or 'smith')? And are there any ministers, male or female, with your first name?

1. For columns holding numeric data or dates, greater than ('`>`'), greater than or equal to ('`>=`'), less than ('`<`') and less than or equal to ('`<=`') operators are also useful.

    The following statement returns all organisations that have a start date on or after the date of the 2010 general election.

    ```sql
    select *
    from organisation
    where
        start_date >= '2010-05-06';
    ```

    **Challenge**: Can you write a query that returns all organisations in the `organisation` table that have a `start_date` of 3 May 1997 or later and an end date of 6 May 2010 or earlier, ordered by `end_date` (`order by` clauses need to be stated after `where` clauses)? This will give you a list of government departments that were both set up and wound up during Labour's time in goverment.[^3]

1. There's also a `between` keyword that is useful when we're interested in a date that's between two possible values, say. Try running the following example and check you're happy with how it operates.

    ```sql
    select *
    from organisation
    where
        start_date between '2010-05-06' and '2024-07-04'
    order by
        start_date;
    ```

    The `between` operator is inclusive - the endpoints are included (6 May 2010 and 4 July 2024 in this case).

### Counts
1. It's often helpful to generate summary statistics based on the data we're working with, such as counts. 

    How many records are there in the `person` table? You can find that out by running:

    ```sql
    select
        count(1)
    from person;
    ```

    What is `count(1)` doing? For every record in the table, it's adding one to the tally. You can use a column name in place of `1` but the results will vary depending whether the column has got any missing (`NULL`) values. Test this by replacing `count(1)` with `count(id)` and `count(start_date)` in the above statement.

    Using `count(id)` you should see you get the same count as when using `count(1)` - indicating that an `id` is present for every record.

1. We often don't want to get an overall count of records, but instead break things down into categories. To do that, we can use SQL's `group by` operator.

    Try running the following query, which calculates tallies of records in the `person` table by `gender`:

    ```sql
    select
        gender,
        count(1)
    from person
    group by
        gender
    order by
        gender;
    ```

    Note that, in addition to the `group by` we've added `gender` to the list of columns in the `select` part of the query and have added an (optional) `order by` too.

    Is this a breakdown of the gender of everyone who's been a minister since 1979? Not quite - there's one more step we need to take.

    When browsing the `person` table earlier, you may have noticed that some people are in there more than once, under different names. (If you didn't notice this, try doing a simple query to look for all records in that table with an `id` equal to '`002a6349-2ee5-44b0-9b33-000baae8c737`'.)[^4]

    To generate a count of _unique_ individuals by gender, we can use the `distinct` keyword as follows:

    ```sql
    select
        gender,
        count(distinct id)
    from person
    group by
        gender
    order by
        gender;
    ```

    This now gives you the correct answer for the gender of everyone who's been a minister since 1979. (Note that we need to use `distinct id` rather than `distinct 1` - as '1' isn't going to be distinct across records.)

    **Challenge**: Adapting the query you used earlier, of the people whose `short_name` ends with 'Smith' or 'smith', how many have been male and how many female?

## Joins
1. The real value in using a SQL database comes when we want to join tables together. Different types of join exist, but in this tutorial we will just use one kind - the `inner join`. In an inner join, something has to exist in _both_ of the tables we're joining in order for a record to be returned (this will be clearer once we see an example).

    First of all, take a quick look at the top 10 records in each of the `post` and `organisation` columns to refamiliarise yourself with the structure of those tables.

    You should see that both tables have an `id` column - unique identifiers for each post and organisation, respectively. In database terms, these are known as the 'primary key'. The `post` table also has an `organisation_id` column. This is what's known as a 'foreign key' column - a column of primary keys that can be found in a different table. The naming of the column tells us it corresponds to the `id` column in the `organisation` table - and it's this that's going to enable us to join the tables together.

    A simple inner join in DuckDB takes the following form:

    ```sql
    select *
    from post t
        inner join organisation o on
            t.organisation_id = o.id
    limit 10;
    ```

    In this case, this query gives us the details of 10 posts including details of the organisation at which the post was based.

    There are a number of things worth highlighting about the query.

    Firstly, we've given the `post` table an _alias_, `t`. We'll see why shortly.

    Secondly, we've specified that we're doing an `inner join` with the `organisation` table - and we've also given that an alias, `o`.

    Finally, we've specified the columns that the join needs to be done on - `organisation_id` in the `post` table (making use of its alias) and the `id` column in the `organisation` table.

1. Often it's helpful to only return the columns we're interested in. The following query gets rid of all of the ID columns (which are essential for doing joins, but not that meaningful when we're browsing the data) and one or two other columns that are also of less interest:

    ```sql
    select
        t.name,
        o.name
    from post t
        inner join organisation o on
            t.organisation_id = o.id
    limit 10;
    ```

    Note that this makes use of the table aliases again when specifying which columns we're interested in - it saves us writing out `post` and `organisation` every time.
    
    **Challenge**: Can you add on the `rank_equivalence` column from the `post` table and order results by the `name` column in the `post` table, so that we're selecting the 10 posts that come first alphabetically, together with the name of the department in which they sat and their `rank_equivalence`? (See the _Initial queries_ section for a description of `rank_equivalence` values if you skipped that section.)

1. At its heart, the database is about tracking which individuals did which posts for which time period. In order to do this, we need to use the `appointment` table, which links people and posts.

    Let's say we want to look at the appointments made when Margaret Thatcher became Prime Minister in May 1979. We'll do this with a query combining the `person`, `appointment` and `post` tables.

    If you take a look at the `appointment` table you should see that it has `person_id` and `post_id` columns, which contain foreign keys for the `person` and `post` tables respectively.

    Try running the following query:

    ```sql
    select
        p.name,
        t.name post_name,
        a.start_date,
        a.end_date
    from person p
        inner join appointment a on
            p.id = a.person_id and
            a.start_date >= coalesce(p.start_date, '1900-01-01') and
            a.start_date < coalesce(p.end_date, '9999-12-31')
        inner join post t on
            a.post_id = t.id
    order by
        a.start_date,
        p.name
    limit 20;
    ```

    The joins between the `person`, `appointment` and `post` tables means we're linking individuals to the post they carried out. We've ordered things by appointment `start_date` and person `name`, and limited results to the top 20 records - meaning you should get the details of 20 appointments that started shortly after the election of May 1979.
    
    There are a few features worth flagging:
    - This gives `t.name` an alias of `post_name` in the results (see the `select` part of the query) - this isn't strictly needed, but helps make clear what the column is when we have mrore than one column called `name`
    - The join of the `person` table to the `appointment` table applies conditions involving dates as well as the condition involving IDs. This is because, as we saw earlier, an individual can appear more than once in the `person` table where they've changed name. Comparing `a.start_date` to `p.start_date` and `p.end_date` means we pick up someone's person characteristics - name and gender - at the point where they _start_ an appointment
    - `coalesce()` is used on the join between the `person` table and the `appointment` table. This has the effect of substituting in a value - '`1900-01-01`' and '`9999-12-31`', respectively (values that are always going to be smaller than/greater than start dates in our dataset) - for `NULL` values. This ensures that, where a `person` record doesn't have a `start_date` or an `end_date` that isn't going to prevent us matching any appointments for that individual.

    **Challenge**: This code snippet can be tweaked to give slightly different results. Can you adapt the code to get details of the first 30 appointments since May 1979 of rank Secretary of State?. See the footnotes if you need some pointers.[^5]

1. Let's add on a join to one final table - `organisation`. This will add details of the organisation at which someone held a post to what our previous query returned - and that will give us a full picture of the appointments people have carried out.

    Adapting the statement above, and using the join between the `post` and `organisation` tables we employed earlier, that would be:

    ```sql
    select
        p.name,
        t.name post_name,
        o.name org_name,
        a.start_date,
        a.end_date
    from person p
        inner join appointment a on
            p.id = a.person_id and
            a.start_date >= coalesce(p.start_date, '1900-01-01') and
            a.start_date < coalesce(p.end_date, '9999-12-31')
        inner join post t on
            a.post_id = t.id
        inner join organisation o on
            t.organisation_id = o.id
    order by
        a.start_date,
        p.name
    limit 20;
    ```

    **Challenge**: Can you adapt that statement to give:
    - All current appointments?[^6]
    - All appointments since May 1979 in the Cabinet Office?[^7]
    - All appointments since May 1979 that lasted less than 30 days? Subtraction between two columns of dates will give you the difference in number of days.[^8] (Note that appointments in the database are considered to end where a post has moved from one department to another - so some of the records you return here, such as Angela Rayner's appointments as Secretary of State for Levelling Up, Housing and Communities and Deputy Prime Minister, in reality lasted more than 30 days. Linking up appointments that span these ['machinery of government changes'](https://www.instituteforgovernment.org.uk/explainer/machinery-government-changes) is possible but beyond the scope of this tutorial)

    Again, see the footnotes for hints.

1. Combining things you've learnt, it's also possible to use `count` in combination with joins.

    Let's say we want to get a count of all appointments since May 1979, broken down by gender. The following query will achieve that:

    ```sql
    select
        p.gender,
        count(1)
    from person p
        inner join appointment a on
            p.id = a.person_id and
            a.start_date >= coalesce(p.start_date, '1900-01-01') and
            a.start_date < coalesce(p.end_date, '9999-12-31')
        inner join post t on
            a.post_id = t.id
        inner join organisation o on
            t.organisation_id = o.id
    group by
        p.gender
    order by
        p.gender;
    ```

    Strictly speaking, we don't really need the joins to the `post` and `organisation` tables to get this answer - but we would for other things we might be interested in exploring. (Note that we've also got rid of the `limit 20`.)

    **Challenge**: Using what you learnt earlier:
    - Can you adapt the query to work out how different the gender balance in appointments looks if we restrict things to appointments since 3 May 1997 (the date of the 1997 general election), or between 6 May 2010 and 4 July 2024 (the 2010 and 2024 general elections)?[^9]
    - Returning to our Smiths, can you calculate tallies of the departments they have held appointments in?[^10]

## Extensions
1. The `appointment_characteristics` table contains some details of _how_ someone did a post - whether they were a [Cabinet](https://www.instituteforgovernment.org.uk/explainer/cabinet) minister, whether they were on leave from an appointment or doing a post in an acting capacity. Each `appointment` record is divided into one or more `appointment_characteristics` records. Can you work out how add this information into your queries?

    To do this you'll need to create the `appointment_characteristics` table, which can be done using:
    ```sql
    create table appointment_characteristics as select * from 'https://raw.githubusercontent.com/instituteforgov/ifg-ministers-database-public/refs/heads/main/data/appointment_characteristics.csv';
    ```

    Can you use this to work out everyone who's been a full cabinet minister since 6 May 2010?[^11]

1. The `representation` table and its related `representation_characteristics` and `constituency` tables contain information, sourced from Parliament, on people's parliamentary representation. Can you work out how to use this information, to break things down by whether someone was an MP or a peer, or look at the constituencies represented by ministers?[^12]

    To do this you'll need to create these tables, which can be done using:
    ```sql
    create table representation as select * from 'https://raw.githubusercontent.com/instituteforgov/ifg-ministers-database-public/refs/heads/main/data/representation.csv';
    create table representation_characteristics as select * from 'https://raw.githubusercontent.com/instituteforgov/ifg-ministers-database-public/refs/heads/main/data/representation_characteristics.csv';
    create table constituency as select * from 'https://raw.githubusercontent.com/instituteforgov/ifg-ministers-database-public/refs/heads/main/data/constituency.csv';
    ```

1. DuckDB can also be used in [Python](https://duckdb.org/docs/api/python/overview) and [R](https://duckdb.org/docs/api/r). Can you work out how to query the database in one of those languages?
1. As well as being available in CSV form, the entire database is available as a [SQLite database](https://github.com/instituteforgov/ifg-ministers-database-public/blob/main/data/ifg-ministers-database.sqlite). Are you able to query that directly (using something other than DuckDB shell) and use some of the [advanced scripts we've made available](https://github.com/instituteforgov/ifg-ministers-database-public/#scripts)?
1. The `person` table includes people's parliamentary (MNIS) identifiers (`id_parliament`). Are you able to join the database up with other parliamentary data, such as from the [Register of Members' Financial Interests](https://www.parliament.uk/mps-lords-and-offices/standards-and-financial-interests/parliamentary-commissioner-for-standards/registers-of-interests/register-of-members-financial-interests/)?

## Further reading
- [The IfG Ministers Database tells us a lot about the last six decades in UK politics](https://www.instituteforgovernment.org.uk/comment/ifg-ministers-database) (launch blogpost)
- [About the IfG Ministers Database](https://www.instituteforgovernment.org.uk/ministers-database/about-database) and [How to use the IfG Ministers Database](https://www.instituteforgovernment.org.uk/ministers-database/how-use-database)
- A nice use of DuckDB by Gregor Aisch: [Using DuckDB to analyze over 95 million taxi rides](https://blog.datawrapper.de/using-duckdb-to-analyze-over-95-million-car-sharing-rides/)

## Queries
For any media queries about the database, please get in touch using: press@instituteforgovernment.org.uk.

For all other queries (e.g. errors in the database, questions or suggestions) please get in touch using: ministers.database@instituteforgovernment.org.uk.

[^1]: DuckDB [uses a variant of PostgreSQL](https://duckdb.org/docs/sql/dialect/overview)
[^2]: The database uses gender rather than sex, as we draw that particular variable from data published by Parliament, and that is the term they use.
[^3]: The eagle-eyed among you might notice that there's a Deputy Prime Minister's Office in both the list of organisations created and wound up between the 1997 general election and the 2010 general election, and those created since the 2010 general election. These are recorded as separate organisations in the database, as there wasn't a DPM's Office in constant existence. This also gives you a flavour of how much governments like to the tinker with Whitehall structures.
[^4]: In the language of databases: we haven't fully de-normalised this table. Other tables in the IfG Ministers Database are denormalised.
[^5]: To do this you'll need a `where` clause using the `rank_equivalence` column in the `post` table.
[^6]: Ongoing appointments have an `end_date` of `NULL`. Rather than using `= null` we use `is null`.
[^7]: This will need a `where` clause, making use of `name` in the `organisation` table.
[^8]: To do this you'll need a `where` clause with `a.end_date - a.start_date < 30` or similar.
[^9]: This will need a `where` clause, making use of `start_date`, or `start_date` and `end_date`, in the `appointment` table.
[^10]: This will also need a `where` clause using `ilike`, as you employed earlier, to select people whose `short_name` ends with 'Smith' or 'smith'. And, rather than grouping on `gender` from the `person` table, you'll need to group on something from the `organisation` table.
[^11]: You'll probably want to switch to using `start_date` and `end_date` from the `appointment_characteristics` table rather than the `appointment` table in doing this.
[^12]: As with use of the `appointment` and `appointment_characteristics` tables, you'll probably want to make use of `start_date` and `end_date` from the `representation` and `representation_characteristics` tables in doing joins to these tables, so that details of parliamentary representation are picked up as at the point someone started an appointment.
