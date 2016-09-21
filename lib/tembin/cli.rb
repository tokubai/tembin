require 'thor'
require 'yaml'
require 'erb'

class Tembin::CLI < Thor
  package_name :Tembin

  desc 'apply', 'apply re:dash files'
  option :file, type: :string, aliases: :f, banner: 'entry file path'
  option :apply, type: :boolean, aliases: :a, banner: 'apply flag(default dry run)'
  option :redash_config, type: :string, aliases: :c, banner: 'redash config file path'
  def apply
    load_redash_credentials

    Tembin::Applyer.run(
      Tembin::ElementParser.parse(dsl_file),
      dry_run: !options[:apply]
    )
  end

  desc 'export', 'export re:dash files'
  option :dir, type: :string, aliases: :d, required: true, banner: 'export file store directory'
  option :redash_config, type: :string, aliases: :c, banner: 'redash config file path'
  option :disable_split_sql, type: :boolean, banner: 'disable sqlfile split mode'
  option :split_file, type: :boolean, banner: 'disable split file mode'
  def export
    load_redash_credentials

    Tembin::Exporter.run(
      Pathname.new(options[:dir]),
      split_sql: !options[:disable_split_sql],
      split_file: options[:split_file],
    )
  end

  private

  def dsl_file
    Pathname.new(options[:file] || 'Redashfile')
  end

  def redash_config_path
    Pathname.new(options[:redash_config] || 'redash.yml')
  end

  def load_redash_credentials
    Tembin::Redash.config = YAML.load(
      ERB.new(
        open(redash_config_path).read
      ).result(binding)
    )

    if Tembin::Redash.config['api_key'].nil?
      raise ArgumentError, "Re:dash api key is empty. Please set Tembin::Redash.config['api_key']"
    end

    if Tembin::Redash.config['authorized_user_email'].nil?
      raise ArgumentError, "Re:dash user login email is empty. Please set Tembin::Redash.config['authorized_user_email']"
    end
  end
end
