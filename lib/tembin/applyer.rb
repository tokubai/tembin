require 'diffy'
require 'highline'

class Tembin::Applyer
  def self.run(elements, dry_run: true, out: STDOUT)
    new(elements, out: out, dry_run: dry_run).run
  end

  def initialize(elements, out: STDOUT, dry_run: true)
    @elements = elements
    @dry_run = dry_run
    @out = out
  end

  def run(dry_run: true)
    remote_queries = Tembin::Redash::Query.created_by_me
    remote_queries.each do |remote_query|
      @out.puts(h.color("#{remote_query.name}", :green))

      update_query(
        remote_query,
        @elements.find{ |e| e.name == remote_query.name },
      )
    end

    remote_query_names = remote_queries.map(&:name)
    @elements.reject { |local|
      remote_query_names.include?(local.name)
    }.each { |element|
      create_new_query(element)
    }
  end

  private

  def create_new_query(local)
    @out.puts(h.color("#{local.name}", :green))
    if @dry_run
      @out.puts(h.color("   --> will be created.", :yellow))
    else
      Tembin::Redash::Query.create(local.name, local.attributes[:sql])
      @out.puts(h.color("   --> create.", :yellow))
    end
  end

  def update_query(remote, local)
    if local.nil?
      if @dry_run
        @out.puts(h.color("   --> will be deleted.", :red))
      else
        @out.puts(h.color("   --> delete.", :red))
        remote.delete!
      end

      @out.puts
      return
    end

    if remote.changed?(local.attributes[:sql])
      @out.puts(h.color("   --> has changed.", :yellow))

      if @dry_run
        @out.puts(Diffy::Diff.new(remote.sql, local.attributes[:sql]).to_s(:color))
      else
        remote.update!(element.attributes[:sql])
        @out.puts(h.color("   --> updated.", :green))
      end
    else
      @out.puts(h.color("   --> already up to date.", :cyan))
    end

    @out.puts
  end

  def h
    @h ||= HighLine.new
  end
end
