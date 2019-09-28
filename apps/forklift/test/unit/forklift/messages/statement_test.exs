defmodule Forklift.Messages.StatementTest do
  use ExUnit.Case
  use Placebo

  alias Forklift.Messages.Statement
  alias SmartCity.TestDataGenerator, as: TDG

  test "build generates a valid statement when given a schema and data" do
    data = [
      %{"id" => 1, "name" => "Fred"},
      %{"id" => 2, "name" => "Gred"},
      %{"id" => 3, "name" => "Hred"}
    ]

    result = Statement.build(dataset(), data)

    expected_result = ~s/insert into "rivers" ("id","name") values row(1,'Fred'),row(2,'Gred'),row(3,'Hred')/

    assert result == expected_result
  end

  test "build generates a valid statement when given a schema and data that are not in the same order" do
    schema = dataset()

    data = [
      %{"name" => "Iom", "id" => 9},
      %{"name" => "Jom", "id" => 8},
      %{"name" => "Yom", "id" => 7}
    ]

    result = Statement.build(schema, data)
    expected_result = ~s/insert into "rivers" ("id","name") values row(9,'Iom'),row(8,'Jom'),row(7,'Yom')/

    assert result == expected_result
  end

  test "escapes single quotes correctly" do
    data = [
      %{"id" => 9, "name" => "Nathaniel's test"}
    ]

    result = Statement.build(dataset(), data)
    expected_result = ~s/insert into "rivers" ("id","name") values row(9,'Nathaniel''s test')/

    assert result == expected_result
  end

  test "inserts null when field is null" do
    data = [
      %{"id" => 9, "name" => nil}
    ]

    result = Statement.build(dataset(), data)
    expected_result = ~s/insert into "rivers" ("id","name") values row(9,null)/

    assert result == expected_result
  end

  test "inserts null when timestamp field is an empty string" do
    dataset = dataset([%{name: "id", type: "integer"}, %{name: "date", type: "timestamp"}])
    data = [%{"id" => 9, "date" => ""}]

    result = Statement.build(dataset, data)
    expected_result = ~s/insert into "rivers" ("id","date") values row(9,null)/

    assert result == expected_result
  end

  test "inserts a presto-appropriate date when inserting a date" do
    dataset = dataset([%{name: "id", type: "number"}, %{name: "start_date", type: "date"}])
    data = [%{"id" => 9, "start_date" => "1900-01-01T00:00:00"}]

    result = Statement.build(dataset, data)

    expected_result =
      ~s/insert into "rivers" ("id","start_date") values row(9,date(date_parse('1900-01-01T00:00:00', '%Y-%m-%dT%H:%i:%S')))/

    assert result == expected_result
  end

  test "inserts 1 when integer field is a signed 1" do
    data = [
      %{"id" => "+1", "name" => "Hroki"},
      %{"id" => "-1", "name" => "Doki"}
    ]

    result = Statement.build(dataset(), data)
    expected_result = ~s/insert into "rivers" ("id","name") values row(1,'Hroki'),row(-1,'Doki')/

    assert result == expected_result
  end

  test "inserts number when float field is a signed number" do
    dataset = dataset([%{name: "id", type: "integer"}, %{name: "floater", type: "float"}])
    data = [%{"id" => "1", "floater" => "+4.5"}, %{"id" => "1", "floater" => "-4.5"}]

    result = Statement.build(dataset, data)
    expected_result = ~s/insert into "rivers" ("id","floater") values row(1,4.5),row(1,-4.5)/

    assert result == expected_result
  end

  test "inserts without timezone when inserting a timestamp" do
    dataset = dataset([%{name: "id", type: "number"}, %{name: "start_time", type: "timestamp"}])
    data = [%{"id" => 9, "start_time" => "2019-04-17T14:23:09.030939"}]

    result = Statement.build(dataset, data)

    expected_result =
      ~s/insert into "rivers" ("id","start_time") values row(9,date_parse('2019-04-17T14:23:09.030939', '%Y-%m-%dT%H:%i:%S.%f'))/

    assert result == expected_result
  end

  test "inserts using proper format when inserting a timestamp" do
    dataset = dataset([%{name: "id", type: "number"}, %{name: "start_time", type: "timestamp"}])
    data = [%{"id" => 9, "start_time" => "2019-06-02T16:30:17"}]

    result = Statement.build(dataset, data)

    expected_result =
      ~s/insert into "rivers" ("id","start_time") values row(9,date_parse('2019-06-02T16:30:17', '%Y-%m-%dT%H:%i:%S'))/

    assert result == expected_result
  end

  test "inserts using proper format when inserting a timestamp that ends in Z" do
    dataset = dataset([%{name: "id", type: "number"}, %{name: "start_time", type: "timestamp"}])
    data = [%{"id" => 9, "start_time" => "2019-06-11T18:34:33.484840Z"}]

    result = Statement.build(dataset, data)

    expected_result =
      ~s/insert into "rivers" ("id","start_time") values row(9,date_parse('2019-06-11T18:34:33.484840Z', '%Y-%m-%dT%H:%i:%S.%fZ'))/

    assert result == expected_result
  end

  test "inserts using proper format when inserting a timestamp that ends in Z without milliseconds" do
    dataset = dataset([%{name: "id", type: "number"}, %{name: "start_time", type: "timestamp"}])
    data = [%{"id" => 9, "start_time" => "2019-06-14T18:16:32Z"}]

    result = Statement.build(dataset, data)

    expected_result =
      ~s/insert into "rivers" ("id","start_time") values row(9,date_parse('2019-06-14T18:16:32Z', '%Y-%m-%dT%H:%i:%SZ'))/

    assert result == expected_result
  end

  test "inserts time data types as strings" do
    dataset = dataset([%{name: "id", type: "number"}, %{name: "start_time", type: "time"}])
    data = [%{"id" => 9, "start_time" => "23:00:13.001"}]

    result = Statement.build(dataset, data)
    expected_result = ~s/insert into "rivers" ("id","start_time") values row(9,'23:00:13.001')/

    assert result == expected_result
  end

  test "handles empty string values with a type of string" do
    data = [
      %{"id" => 1, "name" => "Fred"},
      %{"id" => 2, "name" => "Gred"},
      %{"id" => 3, "name" => ""}
    ]

    result = Statement.build(dataset(), data)
    expected_result = ~s/insert into "rivers" ("id","name") values row(1,'Fred'),row(2,'Gred'),row(3,'')/

    assert result == expected_result
  end

  test "treats json string as varchar" do
    data = [
      %{
        "id" => 1,
        "name" => "Fred",
        "payload" => "{\"parent\":{\"children\":[[-35.123,123.456]],\"id\":\"daID\"}}"
      }
    ]

    result = Statement.build(get_json_schema(), data)

    expected_result =
      ~s/insert into "rivers" ("id","name","payload") values row(1,'Fred','{\"parent\":{\"children\":[[-35.123,123.456]],\"id\":\"daID\"}}')/

    assert result == expected_result
  end

  test "escapes quotes in json" do
    data = [
      %{
        "id" => 1,
        "name" => "Fred",
        "payload" => "{\"parent\":{\"children\":[[-35.123,123.456]],\"id\":\"daID\", \"name\": \"Chiggin's\"}}"
      }
    ]

    result = Statement.build(get_json_schema(), data)

    expected_result =
      ~s|insert into "rivers" ("id","name","payload") values row(1,'Fred','{\"parent\":{\"children\":[[-35.123,123.456]],\"id\":\"daID\", \"name\": \"Chiggin''s\"}}')|

    assert result == expected_result
  end

  test "treats empty string as varchar" do
    data = [%{"id" => 1, "name" => "Fred", "payload" => ""}]

    result = Statement.build(get_json_schema(), data)
    expected_result = ~s/insert into "rivers" ("id","name","payload") values row(1,'Fred','')/

    assert result == expected_result
  end

  test "build generates a valid statement when given a complex nested schema and complex nested data" do
    nested_data = get_complex_nested_data()
    result = Statement.build(get_complex_nested_schema(), nested_data)

    expected_result =
      ~s|insert into "rivers" ("first_name","age","friend_names","friends","spouse") values row('Joe',10,array['bob','sally'],array[row('Bill','Bunco'),row('Sally','Bosco')],row('Susan','female',row('Joel','12/07/1941')))|

    assert result == expected_result
  end

  test "build generates a valid statement when given a map" do
    schema = [
      %{
        name: "first_name",
        type: "string"
      },
      %{
        name: "spouse",
        type: "map",
        subSchema: [%{name: "first_name", type: "string"}]
      }
    ]

    dataset = dataset(schema)

    data = [
      %{"first_name" => "Bob", "spouse" => %{"first_name" => "Hred"}},
      %{"first_name" => "Rob", "spouse" => %{"first_name" => "Freda"}}
    ]

    result = Statement.build(dataset, data)

    expected_result =
      ~s|insert into "rivers" ("first_name","spouse") values row('Bob',row('Hred')),row('Rob',row('Freda'))|

    assert result == expected_result
  end

  test "build generates a valid statement when given nested rows" do
    schema = [
      %{
        name: "spouse",
        type: "map",
        subSchema: [
          %{name: "first_name", type: "string"},
          %{
            name: "next_of_kin",
            type: "map",
            subSchema: [
              %{name: "first_name", type: "string"},
              %{name: "date_of_birth", type: "string"}
            ]
          }
        ]
      }
    ]

    dataset = dataset(schema)

    data = [
      %{
        "spouse" => %{
          "first_name" => "Georgia",
          "next_of_kin" => %{
            "first_name" => "Bimmy",
            "date_of_birth" => "01/01/1900"
          }
        }
      },
      %{
        "spouse" => %{
          "first_name" => "Regina",
          "next_of_kin" => %{
            "first_name" => "Jammy",
            "date_of_birth" => "01/01/1901"
          }
        }
      }
    ]

    result = Statement.build(dataset, data)

    expected_result =
      ~s|insert into "rivers" ("spouse") values row(row('Georgia',row('Bimmy','01/01/1900'))),row(row('Regina',row('Jammy','01/01/1901')))|

    assert result == expected_result
  end

  test "build generates a valid statement when given an array" do
    dataset = dataset([%{name: "friend_names", type: "list", itemType: "string"}])
    data = [%{"friend_names" => ["Sam", "Jonesy"]}, %{"friend_names" => []}]

    result = Statement.build(dataset, data)
    expected_result = ~s|insert into "rivers" ("friend_names") values row(array['Sam','Jonesy']),row(array[])|

    assert result == expected_result
  end

  test "build generates a valid statement when given a date" do
    dataset = dataset([%{name: "date_of_birth", type: "date"}])
    data = [%{"date_of_birth" => "1901-01-01T00:00:00"}, %{"date_of_birth" => "1901-01-21T00:00:00"}]

    result = Statement.build(dataset, data)

    expected_result =
      ~s|insert into "rivers" ("date_of_birth") values row(date(date_parse('1901-01-01T00:00:00', '%Y-%m-%dT%H:%i:%S'))),row(date(date_parse('1901-01-21T00:00:00', '%Y-%m-%dT%H:%i:%S')))|

    assert result == expected_result
  end

  test "build generates a valid statement when given an array of maps" do
    schema = [
      %{
        name: "friend_groups",
        type: "list",
        itemType: "map",
        subSchema: [
          %{name: "first_name", type: "string"},
          %{name: "last_name", type: "string"}
        ]
      }
    ]

    dataset = dataset(schema)

    data = [
      %{
        "friend_groups" => [
          %{"first_name" => "Hayley", "last_name" => "Person"},
          %{"first_name" => "Jason", "last_name" => "Doe"}
        ]
      },
      %{
        "friend_groups" => [
          %{"first_name" => "Saint-John", "last_name" => "Johnson"}
        ]
      }
    ]

    result = Statement.build(dataset, data)

    expected_result =
      ~s|insert into "rivers" ("friend_groups") values row(array[row('Hayley','Person'),row('Jason','Doe')]),row(array[row('Saint-John','Johnson')])|

    assert result == expected_result
  end

  defp dataset(schema \\ [%{name: "id", type: "integer"}, %{name: "name", type: "string"}]) do
    TDG.create_dataset(%{technical: %{systemName: "rivers", schema: schema}})
  end

  defp get_json_schema() do
    dataset([
      %{name: "id", type: "integer"},
      %{name: "name", type: "string"},
      %{name: "payload", type: "json"}
    ])
  end

  defp get_complex_nested_schema() do
    schema = [
      %{name: "first_name", type: "string"},
      %{name: "age", type: "integer"},
      %{name: "friend_names", type: "list", itemType: "string"},
      %{
        name: "friends",
        type: "list",
        itemType: "map",
        subSchema: [
          %{name: "first_name", type: "string"},
          %{name: "pet", type: "string"}
        ]
      },
      %{
        name: "spouse",
        type: "map",
        subSchema: [
          %{name: "first_name", type: "string"},
          %{name: "gender", type: "string"},
          %{
            name: "next_of_kin",
            type: "map",
            subSchema: [
              %{name: "first_name", type: "string"},
              %{name: "date_of_birth", type: "string"}
            ]
          }
        ]
      }
    ]

    dataset(schema)
  end

  defp get_complex_nested_data() do
    [
      %{
        "first_name" => "Joe",
        "age" => 10,
        "friend_names" => ["bob", "sally"],
        "friends" => [
          %{"first_name" => "Bill", "pet" => "Bunco"},
          %{"first_name" => "Sally", "pet" => "Bosco"}
        ],
        "spouse" => %{
          "first_name" => "Susan",
          "gender" => "female",
          "next_of_kin" => %{
            "first_name" => "Joel",
            "date_of_birth" => "12/07/1941"
          }
        }
      }
    ]
  end
end
