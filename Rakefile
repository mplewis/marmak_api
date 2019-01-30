BLUE = "\e[34m"
RESET = "\e[39m"

def run(cmd)
  c = cmd.gsub(/\s+/, ' ')
  puts "#{BLUE}#{c}#{RESET}"
  begin
    system c
  rescue Interrupt
    exit
  end
end

def read(fn)
  File.open(fn).read.chomp
end

task :serve do
  run <<~CMD
    find hello_world | entr -r -s 'sam build; sam local start-api'
  CMD
end

task :package do
  run 'sam build'
  run <<~CMD
    sam package
      --template-file .aws-sam/build/template.yaml
      --output-template-file packaged.yaml
      --s3-bucket "#{read '.s3_bucket'}"
  CMD
end

task :deploy do
  run <<~CMD
    aws cloudformation deploy
      --template-file /Users/mplewis/code/other/marmak_api/packaged.yaml
      --capabilities CAPABILITY_IAM
      --stack-name "#{read '.stack_name'}"
  CMD
end

task :query do
  run <<~CMD
    aws cloudformation describe-stacks
      --stack-name "#{read '.stack_name'}"
      --query 'Stacks[].Outputs'
  CMD
end