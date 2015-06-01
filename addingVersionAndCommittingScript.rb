namespace :ci do

  desc "Increases the minor version, and commits the changes. version x.y.z will be x.y.z+1"
  task :bump_build =&gt; :environment do
    version = get_splitted_version
    version[1] = (version[1].to_i + 1).to_s
    bump_version('v' + version.join('.'))
  end

  def get_splitted_version
    version = File.read("config/version.yml")
    version = version[7..-1]
    version.split('.')
  end

  def bump_version(version)

    write_version_yml(version)
    add_version_to_release_notes(version)

    exec_command("git add config/version.yml")
    exec_command("git add doc/release_notes.md")
    exec_command("git commit -m 'bump version #{version}' config/version.yml doc/release_notes.md")

    tag_version(version)
  end

  def write_version_yml(version)
    File.open("config/version.yml", 'w') { |f| f.write("name: #{version}") }
  end

  def add_version_to_release_notes(version)
    version_addition = "# version #{version}"
    version_addition += "\n#### #{Time.now.to_formatted_s(:long)}"
    version_addition = "\n\n" + version_addition + "\n" + "-" * version_addition.length + "\n\n"
  end

  def tag_version(version)
    exec_command("git tag #{version} -a  -m '#{version}'")
    exec_command("git push origin #{version}")
  end

  def exec_command(cmd)
    puts "Executing - '#{cmd}'..."
    success = system(cmd)
    raise "'#{cmd}' exited with code:#{$?.exitstatus}." if !success
  end
end
