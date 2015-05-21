require 'json'
require 'rest-client'

class Spider

  def crawl_basic_infos(yearterm=1031)
    url = "http://itouch.cycu.edu.tw/active_system/CourseQuerySystem/GetCourses.jsp?yearTerm=#{yearterm}"
    r = RestClient.get url
    data = r.to_s.strip

    rows = data.split('@')
    @courses = []
    rows.each {|r| @courses << make_course(r)}
    # File.open('courses_basic_info.json', 'w') {|f| f.write(JSON.pretty_generate(@courses[1..-1]))}
    File.open('courses.json', 'w') {|f| f.write(JSON.pretty_generate(@courses[1..-1]))}
  end

  def batch_download_books
    codes = @courses.map {|c| c["code"]}
    codes.each do |c|
      puts "load #{c}"
      system("phantomjs spider.js #{c}")
    end
  end

  def map_book_data
    @courses.each do |c|
      filename = "book_datas/#{c[:code]}"
      if File.exist?(filename)
        textbook = JSON.parse(File.read(filename))
        c[:textbook] = textbook
      end
    end
  end

  def save
    File.open('courses.json', 'w') {|f| f.write(JSON.pretty_generate(@courses))}
  end

  private
    def make_course(row)
      course = row.split('|')
      unless course[6].nil?
        department_code = course[6][0..1]
        url = "http://cmap.cycu.edu.tw:8080/Syllabus/CoursePreview.html?yearTerm=1032&opCode=#{course[6]}"
      end
      required = course[11].include?('必') unless course[11].nil?

      time1 = course[16]
      loc1 = course[17]
      time2 = course[18]
      loc2 = course[19]
      time3 = course[20]
      loc3 = course[21]

      periods = []
      periods.concat(make_period(time1, loc1))
      periods.concat(make_period(time2, loc2))
      periods.concat(make_period(time3, loc3))
      periods.each_with_index {|d,i| periods.delete_at(i) if d.nil? }

      {
        # cros_inst: course[1], # 跨部
        # cros_dep: course[2], # 跨系
        # course[4] # 停休與否
        # pho_code: course[5], # 語音代碼
        code: course[6], # 課程代碼
        # category: course[7], # 課程類別
        department: course[8], # 權責單位?
        department_code: department_code,
        # clas: course[9], # 開課班級
        name: course[10], # 課程名稱
        required: required, # 必選修
        # year: course[12], # 全半年
        year: 2014,
        term: 1,
        # course[13] # ?
        credits: course[14], # 學分
        lecturer: course[15], # 授課教師
        periods: periods,
        # time1: course[16], # 時間1
        # loc1: course[17], # 地點1
        # time2: course[18], # 時間2
        # loc2: course[19], # 地點2
        # time3: course[20], # 時間3
        # loc3: course[21], # 地點3
        # notes: course[22], # 備註
        # department: course[23], # 權責單位?
        # people: course[24], # 開課人數
        # url: url
      }
    end

    def make_period(tim, loc)
      # 4-34
      ps = []
      m = tim && tim.match(/(?<d>.)\-(?<p>.+)/)
      if !!m
        m[:p].split("").each do |period|
          chars = []
          chars << m[:d]
          chars << period
          chars << loc
          ps << chars.join(",")
        end
      end
      return ps
    end

end

spider = Spider.new
spider.crawl_basic_infos
# spider.batch_download_books
# spider.map_book_data
# spider.save
