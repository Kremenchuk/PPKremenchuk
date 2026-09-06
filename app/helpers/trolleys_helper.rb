module TrolleysHelper
  # Every trolley model shown on the index page. The markup used to be
  # copy-pasted 15 times (~32 KB of HAML); it is now one partial driven by
  # this table.
  #
  #   code      – value posted as `vid`, also the visible model name
  #   image     – file under app/assets/images/trolleys
  #   flag      – Constant column; the on-line calculator is shown when it
  #               is false (that is how the original view tested it)
  #   materials – i18n keys under page.trolleys.index
  TROLLEY_MODELS = [
    { code: 'TP-01', image: 'telegka_TP_01.png', flag: :on_off_calc_TP01,
      materials: %w[pipe corner laminar_dsp powder_paint] },
    { code: 'TP-02', image: 'telegka_TP_02.png', flag: :on_off_calc_TP02,
      materials: %w[pipe corner laminar_dsp powder_paint] },
    { code: 'TP-03', image: 'telegka_TP_03.png', flag: :on_off_calc_TP03,
      materials: %w[pipe corner laminar_dsp powder_paint] },
    { code: 'TP-04', image: 'telegka_TP_04.png', flag: :on_off_calc_TP04,
      materials: %w[pipe corner laminar_dsp powder_paint] },
    { code: 'TP-05', image: 'telegka_TP_05.png', flag: :on_off_calc_TP05,
      materials: %w[pipe corner laminar_dsp powder_paint] },
    { code: 'TP-06', image: 'telegka_TP_06.png', flag: :on_off_calc_TP06,
      materials: %w[pipe corner list powder_paint] },
    { code: 'TP-07', image: 'telegka_TP_07.png', flag: :on_off_calc_TP07,
      materials: %w[pipe corner list powder_paint] },
    { code: 'KS-01', image: 'telegka_KS_01.png', flag: :on_off_calc_KS01,
      materials: %w[pipe corner list_or_dsp setka powder_paint] },
    { code: 'KS-02', image: 'telegka_KS_02.png', flag: :on_off_calc_KS02,
      materials: %w[pipe corner list_or_dsp setka powder_paint] },
    { code: 'KS-03', image: 'telegka_KS_03.png', flag: :on_off_calc_KS03,
      materials: %w[pipe corner list_or_dsp setka powder_paint] },
    { code: 'KS-04', image: 'telegka_KS_04.png', flag: :on_off_calc_KS04,
      materials: %w[pipe corner list_or_dsp setka powder_paint] },
    { code: 'PT-01', image: 'telegka_PT_01.png', flag: :on_off_calc_PT01,
      materials: %w[pipe list setka powder_paint] },
    { code: 'PT-02', image: 'telegka_PT_02.png', flag: :on_off_calc_PT02,
      materials: %w[pipe list powder_paint] },
    { code: 'PT-03', image: 'telegka_PT_03.png', flag: :on_off_calc_PT03,
      materials: %w[pipe corner laminar_dsp powder_paint] },
    { code: 'PT-04', image: 'telegka_PT_04.png', flag: :on_off_calc_PT04,
      materials: %w[pipe corner setka laminar_dsp powder_paint] }
  ].freeze

  def trolley_models
    TROLLEY_MODELS
  end

  # The calculator is enabled when the Constant flag is false (legacy
  # semantics: the flag switches the calculation *off*).
  def trolley_calc_enabled?(model)
    @constant.present? && @constant.public_send(model[:flag]) == false
  end

  # Unique DOM id per model, so the 15 forms on the page do not collide.
  def trolley_field_id(model, field)
    "#{field}_#{model[:code].tr('-', '_')}"
  end
end
