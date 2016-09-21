class Tembin::Exporter
  def self.run(out_dir, split_sql: true, split_file: true, out: STDOUT)
    new(out_dir, split_sql: split_sql, split_file: split_file, out: STDOUT).run
  end

  def initialize(out_dir, split_sql: true, split_file: true, out: STDOUT)
    @out_dir = out_dir
    @split_sql_mode = split_sql
    @split_file_mode = split_file
    @out = out
  end

  def run
    FileUtils.rm_f(@out_dir.join('tembin.rb')) if File.exist?(@out_dir.join('tembin.rb'))

    export_head_file if @split_file_mode

    Tembin::Redash::Query.created_by_me.each do |query|
      @out.puts(h.color("export #{query.name}", :green))

      file =
        if @split_file_mode
          File.open(@out_dir.join("#{query.filename}.rb"), "w")
        else
          File.open(@out_dir.join("tembin.rb"), "a")
        end

      @out.puts(h.color("   redash query file --> #{file.path}", :yellow))

      sql =
        if @split_sql_mode
          path = @out_dir.join("#{query.filename}.sql")
          File.write(path, query.sql)
          @out.puts(h.color("   sql --> #{path}", :yellow))
          "open(File.join(__dir__, '#{query.filename}.sql')).read"
        else
          "%(#{query.sql})"
        end

      file.puts(<<EOS)
query "#{query.name}" do
  sql #{sql}
end\n
EOS
      file.close

      @out.puts
    end
  end

  private

  def export_head_file
    File.open(@out_dir.join('tembin.rb'), "w") do |file|
      @out.puts(h.color("export head file --> #{file.path}", :green))

      file.puts(<<EOS)
Dir.glob(File.join(__dir__, "*.rb")) do |file|
  next if File.expand_path(file) == File.expand_path('#{file.path}')
  instance_eval(open(file).read, file, 1)
end
EOS
    end
  end

  def h
    @h ||= HighLine.new
  end
end
