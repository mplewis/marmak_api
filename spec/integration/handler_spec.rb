require_src 'app'

describe 'handler' do
  subject { lambda_handler({event: event, context: ctx}) }
  let(:event) { { 'body' => req_body.to_json } }
  let(:ctx) { {} }
  let(:resp) { subject }
  let(:status) { resp[:statusCode] }
  let(:body) { JSON.parse resp[:body] }
  let(:config_h) { body['configuration_h'] }
  let(:config_lines) { config_h.split "\n" }
  let(:error_message) { body['message'] }
  let(:errors) { body['errors'] }

  context 'with params' do
    let(:req_body) { { 'params' => params } }

    context 'with valid params' do
      let(:params) { { board_name: 'CR10' } }

      it 'returns a configuration' do
        expect(status).to be 200
        expect(body).to_not include 'nil'
        puts config_h
        expect(config_lines).to include(
          '#define CONFIGURATION_H',
          '#define CR10',
          '#define LCD_LANGUAGE en'
        )
      end
    end

    context 'with empty params' do
      let(:params) { {} }

      it 'returns the expected error' do
        expect(status).to be 400
        expect(error_message).to eql 'Invalid params'
        expect(errors).to eql({ 'board_name' => ['Missing mandatory key :board_name'] })
      end
    end

    context 'with invalid params' do
      let(:params) { { board_name: 'CR!0', ezout_enable: 1, ezabl_points: 5.6 } }

      it 'returns the expected errors' do
        expect(status).to be 400
        expect(error_message).to eql 'Invalid params'
        expect(errors).to eql({
          'board_name' =>
            ['Value for key :board_name must be one of ["CR10", "CR10_MINI", "CR10_S4", "CR10_S5"], got "CR!0"'],
          'ezout_enable' =>
            ['Value for key :ezout_enable must be true or false, got 1'],
          'ezabl_points' =>
            ['Value for key :ezabl_points must be an integer, got 5.6'],
        })
      end
    end

    context 'with non-hash params' do
      let(:params) { ['CR-10'] }

      it 'returns the expected error' do
        expect(status).to be 400
        expect(error_message).to eql 'Expected `params` to be a hash, got Array'
      end
    end
  end

  context 'when params are missing' do
    let(:req_body) { {} }

    it 'returns the expected error' do
      expect(status).to be 400
      expect(error_message).to eql 'Missing key `params`'
    end
  end
end
