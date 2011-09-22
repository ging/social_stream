# Rake task to launch multiple Resque workers in development/production with simple management included

require 'resque/tasks'    # Require Resque tasks

namespace :workers do

  # = $ rake workers:start
  #
  # Launch multiple Resque workers with the Rails environment loaded,
  # so they have access to your models, etc.
  #
  # Each worker is being run in their own separate process (_not_ thread).
  #
  # On clean shutdown (SIGINT / Ctrl-C, SIGQUIT, SIGTERM), the task will clean
  # after itself: kill its workers and delete PID files, when appropriate. It
  # will deal fine with already dead workers.
  #
  #
  # Default options like COUNT can and should be over-ridden when invoking, of course:
  #
  #    $ rake workers:start COUNT=10 QUEUE=my_queue
  #
  #
  # To daemonize, simply run with nohup:
  #
  #    $ nohup rake workers:start > log/workers.log 2>&1 &
  #
  #
  # You can and should set up your monitoring tool to watch for process with PID
  # from `cat tmp/pids/resque/master.pid`.
  #
  # For proper monitoring of _individual_ workers, use provided examples for God or Monit:
  # http://github.com/defunkt/resque/blob/master/examples/.
  #
  #
  # A task for killing all workers on the machine (`rake workers:killall`) is also provided,
  # for pruning orphaned workers etc.
  #
  desc "Run and manage group of Resque workers with some default options"
  task :start => :environment do

    # - CONFIGURATION ----
    ENV['QUEUE']   ||= '*'
    ENV['COUNT']   ||= '3'
    # --------------------

    def queue
      ENV['QUEUE']
    end

    def count
      ENV['COUNT']
    end

    def Process.exists?(pid)
      kill(0, pid.to_i) rescue false
    end

    def pid_directory
      @pid_directory ||= Rails.root.join('tmp', 'pids', "resque")
    end

    def pid_directory_for_group
      @pid_directory_for_group ||= Rails.root.join('tmp', 'pids', "resque", queue)
    end

    def group_master_pid
      File.read pid_directory.join("#{queue}.pid").to_s rescue nil
    end

    def group?
      !group_master_pid || group_master_pid.to_s == Process.pid.to_s
    end

    def group_running?
      Process.exists?(group_master_pid)
    end

    def kill_worker(pid)
      Process.kill("QUIT", pid)
      puts "Killed worker with PID #{pid}"
      rescue Errno::ESRCH => e
        puts " STALE worker with PID #{pid}"
    end

    def kill_workers
      @pids.each { |pid| kill_worker(pid) }
    end

    def kill_workers_and_remove_pids_for_group
      Dir.glob(pid_directory_for_group.join('worker_*.pid').to_s) do |pidfile|
        begin
          pid = pidfile[/(\d+)\.pid/, 1].to_i
          kill_worker(pid)
        ensure
          FileUtils.rm pidfile, :force => true
        end
      end
      if group_master_pid
        FileUtils.rm    pid_directory.join("#{queue}.pid").to_s
        FileUtils.rm_rf pid_directory_for_group.to_s
      end
    end

    def shutdown
      puts "\n*** Exiting"
      if group?
        kill_workers_and_remove_pids_for_group
      else
        kill_workers
      end
      exit(0)
    end

    # Clean up after dead group from before -- and become one
    unless group_running?
      puts "--- Cleaning up after previous group (PID: #{group_master_pid})"
      kill_workers_and_remove_pids_for_group 
    end

    # Handle exit
    trap('INT')  { shutdown }
    trap('QUIT') { shutdown }
    trap('TERM') { shutdown }
    trap('KILL') { shutdown }
    trap('SIGKILL') { shutdown }

    puts "=== Launching #{ENV['COUNT']} worker(s) on '#{ENV['QUEUE']}' queue(s) with PID #{Process.pid}"

    # Launch workers in separate processes, saving their PIDs
    @pids = []
    ENV['COUNT'].to_i.times do
      @pids << Process.fork { Rake::Task['resque:work'].invoke }
    end

    if group?
      # Make sure we have directory for pids
      FileUtils.mkdir_p pid_directory.to_s
      FileUtils.mkdir_p pid_directory_for_group.to_s
      # Create PID files for workers
      File.open( pid_directory.join("#{queue}.pid").to_s, 'w' ) do |f| f.write Process.pid end
      @pids.each do |pid|
        File.open( pid_directory_for_group.join("worker_#{pid}.pid").to_s, 'w' ) { |f| f.write pid }
      end
      # Stay in foreground, if any of our workers dies, we'll get killed so Monit/God etc can come to the resq^Hcue
      Process.wait
    else
      # Stay in foreground, if any of our workers dies, continue running
      Process.waitall
    end
  end

  desc "Kill ALL workers on this machine"
  task :kilall do
    require 'resque'
    Resque::Worker.all.each do |worker|
      puts "Shutting down worker #{worker}"
      host, pid, queues = worker.id.split(':')
      Process.kill("QUIT", pid.to_i)
    end
  end

end