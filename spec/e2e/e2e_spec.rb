require 'json'
require 'shell'

def request(json)
  sh = Shell.new
  pipe = sh.echo(json) | sh.system('sam local invoke')
  JSON.parse pipe.to_s
end

describe 'End-to-end' do
  subject { request req_body.to_json }
  let(:req_body) { {params: params} }
  let(:res_body) { JSON.parse subject['body'] }

  context 'with a valid board name given' do
    let(:params) { {board_name: 'CR10'} }

    it 'returns the expected Configuration.h' do
      expect(subject['statusCode']).to eql 200

      config = res_body['configuration_h']
      config_lines = config.split("\n").uniq

      expect(config).to_not include 'nil'
      expect(config_lines).to include '#define CR10', '#define UNIFIED_VERSION "TH3D U1.R2.2"'
    end
  end
end
