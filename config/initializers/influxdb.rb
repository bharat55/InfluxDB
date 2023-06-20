client = InfluxDB2::Client.new(
    'http://localhost:8086',
    '0R3kfE_zAdM7IPj0TjG030ukCsJjYRmrbGIbA2ayggNW_ucgky4JQG5YelDjiiKCqCelQqXKTrlO6NqRb6u2kA==',
    bucket: 'bharat',
    org: 'GEMS',
    precision: InfluxDB2::WritePrecision::NANOSECOND,
    use_ssl: false
)
write_api = client.create_write_api

ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, started, finished, unique_id, data|
    hash = {
        name: "process_action.action_controller",
        tags: { 
            method: "#{data[:controller]}##{data[:action]}",
            format: data[:format],
            http_method: data[:method],
            status: data[:status],
            exception: data[:exception]&.first
         },
         fields: {
            time_in_controller: (finished - started) * 1000,
            time_in_view: (data[:view_runtime] || 0).ceil,
            time_in_db: (data[:db_runtime] || 0).ceil,
        },
        time: started
    }

    write_api.write(data: hash)
end

ActiveSupport::Notifications.subscribe "render_template.action_view" do |name, started, finished, unique_id, data|
    hash = {
        name: "render_template.action_view",
        tags: { 
            identifier: data[:identifier],
            layout: data[:layout],
            exception: data[:exception]&.first
         },
         fields: {
            duration: (finished - started) * 1000
        },
        time: started
    }

    write_api.write(data: hash)
end

ActiveSupport::Notifications.subscribe "sql.active_record" do |name, started, finished, unique_id, data|
    hash = {
        name: "sql.active_record",
        tags: { 
            name: data[:name],
            statement_name: data[:statement_name],
            exception: data[:exception]&.first
         },
         fields: {
            duration: (finished - started) * 1000
        },
        time: started
    }

    write_api.write(data: hash)
end

ActiveSupport::Notifications.subscribe "instantiation.active_record" do |name, started, finished, unique_id, data|
    hash = {
        name: "instantiation.active_record",
        tags: { 
            class_name: data[:class_name],
            exception: data[:exception]&.first
         },
         fields: {
            duration: (finished - started) * 1000,
            record_count: data[:record_count]
        },
        time: started
    }

    write_api.write(data: hash)
end