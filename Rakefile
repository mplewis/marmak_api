BLUE = "\e[34m"
RESET = "\e[39m"

SRC_DIR = 'src'

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

def stack
  read '.stack_name'
end

def bucket
  read '.s3_bucket'
end

task :serve do
  run <<~CMD
    find "#{SRC_DIR}" |
    entr -r -s 'sam build; sam local start-api'
  CMD
end

task :package do
  run 'sam build'
  run <<~CMD
    sam package
      --template-file .aws-sam/build/template.yaml
      --output-template-file packaged.yaml
      --s3-bucket "#{bucket}"
  CMD
end

task :deploy do
  run <<~CMD
    aws cloudformation deploy
      --template-file packaged.yaml
      --capabilities CAPABILITY_IAM
      --stack-name "#{stack}"
  CMD
end

task :query do
  run <<~CMD
    aws cloudformation describe-stacks
      --stack-name "#{stack}"
      --query 'Stacks[].Outputs'
  CMD
end