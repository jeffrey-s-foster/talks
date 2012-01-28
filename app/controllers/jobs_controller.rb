class JobsController < ApplicationController
  before_filter :require_site_admin

  def index
    @jobs = Delayed::Job.all.sort { |a,b| a.created_at <=> b.created_at }
  end

  def delete
    @job = Delayed::Job.find(params[:id])
    tm = @job.created_at
    cls = @job.handler.object.class
    @job.destroy
    flash[:notice] = "Deleted #{cls} job that was created at #{tm}"

    redirect_to jobs_index_path
  end

  def delete_all
    Delayed::Job.all.each { |j|
      j.destroy
    }
    flash[:notice] = "Deleted all jobs"

    redirect_to jobs_index_path
  end

  def do_start
    runcmd "#{::Rails.root}/script/delayed_job restart"
    flash[:notice] = @out.html_safe
    redirect_to jobs_index_path
  end

  def do_stop
    runcmd "#{::Rails.root}/script/delayed_job stop"
    flash[:notice] = @out.html_safe
    redirect_to jobs_index_path
  end

  def do_restart
    runcmd "#{::Rails.root}/script/delayed_job restart"
    flash[:notice] = @out.html_safe
    redirect_to jobs_index_path
  end

  def do_reload
    runcmd "#{::Rails.root}/script/delayed_job reload"
    flash[:notice] = @out.html_safe
    redirect_to jobs_index_path
  end

  def do_status
    runcmd "#{::Rails.root}/script/delayed_job status"
    flash[:notice] = @out.html_safe
    redirect_to jobs_index_path
  end

private

  def runcmd(cmd)
    @out = "" if not @out
    @success = true if @success == nil
    @out << "<span class=\"command\">shell$ #{cmd}</span><br/>"
    res = `#{cmd} 2>&1`
    @out << res.gsub("\n", "<br/>")
    if $?.exitstatus != 0 then
      error "Command returned #{$?.exitstatus}"
    end
    res
  end

  def note(s)
    @out = "" if not @out
    @out << "<span class=\"note\">#{s}</span><br/>"
  end

  def error(s)
    @out = "" if not @out
    logger.error "ERROR: #{s}"
    @out << "<span class=\"error\">#{s}</span><br/>"
    @success = false
  end
end
