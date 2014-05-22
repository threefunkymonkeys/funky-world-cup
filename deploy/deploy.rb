#! /usr/bin/env ruby

require "open3"

ROOT = "/srv/http/funky-world-cup"

ENV["PATH"]          = "/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/sbin:/usr/local/bin"
ENV["GIT_WORK_TREE"] = "#{ROOT}"
ENV["BASE"]          = ROOT

$error = false

at_exit do
  if $error
    err "\nDEPLOYMENT CANCELLED"
  else
    run "rm #{ROOT}/public/.maintenance"
  end
end

def out(str)
  str.split("\n").each do |line|
    line.rstrip!
    line.encode!("utf-8", invalid: :replace, undef: :replace)
    puts line
  end
end

def err(str)
  str.split("\n").each do |line|
    line.rstrip!
    line.encode!("utf-8", invalid: :replace, undef: :replace)
    puts "\033[1;37;41m#{line}\033[0m"
  end
end

def run(cmd)
  puts "$ #{cmd}"
  Open3.popen3(ENV, cmd) do |sin, sout, serr, wait|
    status = wait.value

    out sout.read

    if status.success?
      out serr.read
    else
      $error = true
      err serr.read
      err "`#{cmd}` exited with code #{status.exitstatus}"
      exit 1
    end
  end
rescue => ex
  $error = true
  err ex.message
  ex.backtrace.map{ |t| err "\t#{t}" if t.include?($0) }
  exit 2
end

run "git checkout -f"

run "touch #{ROOT}/public/.maintenance"

Dir.chdir(ROOT)

run "sudo dep install"

def read_vars(file)
  {}.tap do |h|
    open("#{ROOT}/#{file}") do |fp|
      fp.lines.each do |line|
        next if line.start_with?("#") || line.strip.empty?
        name, value = line.split("=", 2)
        h[name] = value.strip
      end
    end
  end
end

if File.exist?('env.sh')
  current_env = read_vars("env.sh")
  sample_env  = read_vars("development.env.sh.sample")

  current_env.each do |name, value|
    unless sample_env[name]
      out "Remove deprecated environment variable `#{name}` (#{value})"
      current_env.delete name
    end
  end

  sample_env.each do |name, value|
    unless current_env[name]
      out "Add new environment variable `#{name}` with default value #{value}"
      current_env[name] = value
    end
  end

  open("#{ROOT}/env.sh", "w") do |fp|
    current_env.each do |name, value|
      fp.write "#{name}=#{value}\n"
    end
  end
end

# Restart services if script is provided
SERVICES_PATH = ROOT + "/deploy/fwc_services"
if File.exist?(SERVICES_PATH)
  run "$(which bash) #{SERVICES_PATH}"
end
