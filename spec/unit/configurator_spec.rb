require_src 'configurator'

describe Configurator do
  let(:valid_params) {{
    board_name: 'CR10', # defcontents
    thermistor: 'V6_HOTEND', # defcontentsif
    lcd_language: 'fr', # defval
    ezabl_points: 10, # defval
    heaters_on_during_probing: true, # defif
    ezabl_outside_grid_compensation: false # defif, default: true
  }}

  describe '.generate' do
    subject { described_class.generate valid_params }
    let(:lines) { subject.split "\n" }

    it 'includes the correct items and squishes large spaces' do
      expect(lines).to include(
        '#define CR10',
        '#define V6_HOTEND',
        '#define LCD_LANGUAGE fr',
        '#define EZABL_POINTS 10',
        '#define HEATERS_ON_DURING_PROBING',
      )
      expect(subject).to_not include "\n\n\n"
      expect(subject).to_not include '#define EZABL_OUTSIDE_GRID_COMPENSATION'
      expect(lines.map(&:strip)).to_not include '#define'
    end
  end

  context 'validations' do
    let(:invalid_params) {{
      # no mandatory board name
      # non-boolean flag
      ezout_enable: 'no_thanks',
      # invalid thermistor type
      thermistor: 'NEW_FANGLED_HEATY_BOI',

      # incorrect types
      ezabl_points: 12.5,
      dual_hotend_x_distance: '9',

      # some stuff that's actually valid
      lcd_language: 'fr',
      heaters_on_during_probing: true,
    }}

    describe '.errors' do
      subject { described_class.errors params }

      context 'with valid params' do
        let(:params) { valid_params }
        it { is_expected.to be_empty }
      end

      context 'with invalid params' do
        let(:params) { invalid_params }
        it { is_expected.to eql(
          board_name: ["Missing mandatory key :board_name"],
          ezout_enable: ['Value for key :ezout_enable must be true or false, got "no_thanks"'],
          ezabl_points: ["Value for key :ezabl_points must be an integer, got 12.5"],
          dual_hotend_x_distance: ['Value for key :dual_hotend_x_distance must be a float, got "9"'],
          thermistor: [
            <<~MSG.squish
              Value for key :thermistor must be one of
              [nil, "V6_HOTEND", "TH3D_HOTEND_THERMISTOR", "TH3D_BED_THERMISTOR", "KEENOVO_TEMPSENSOR"],
              got "NEW_FANGLED_HEATY_BOI"
            MSG
          ],
        )}
      end
    end
  end
end
