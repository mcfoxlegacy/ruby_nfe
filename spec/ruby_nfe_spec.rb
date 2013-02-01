# encoding: utf-8
require 'spec_helper'

describe "funções formatação" do
  context "usando função f" do
		it "deve retornar vazio caso parametro seja vazio" do
			f(nil).should be_nil
		end

		context "forçando máscara" do
			it "deve retornar fone no formato '(99) 9999-9999'" do
				f('1234567890', {:mask => :fone}).should eq '(12) 3456-7890'
			end		

			it "deve retornar cep no formato '99999-999'" do
				f('98920000', {:mask => :cep}).should eq '98920-000'
			end		

			it "deve retornar cpf no formato '111.111.111-11'" do
				f('11111111111', {:mask => :cpf}).should eq '111.111.111-11'
			end		

			it "deve retornar cnpj no formato '99.999.999/9999-99'" do
				# http://www.geradorcnpj.com.br
				f('59384326000102', {:mask => :cnpj}).should eq '59.384.326/0001-02'
			end		

			it "deve retornar chave no formato '99 9999 99999999999999 99 999 999999999 9 99999999 9'" do
				f('99999999999999999999999999999999999999999999', {:mask => :chave}).should 
				eq '99 9999 99999999999999 99 999 999999999 9 99999999 9'
			end
		end

		context "pelo tamanho do parâmetro" do
			it "deve retornar o mesmo parâmetro caso não combine tamanho" do
				f('abcdefg').should eq 'abcdefg'
			end

			it "deve retornar cep no formato '99999-999'" do
				f('98920000').should eq '98920-000'
			end		

			it "deve retornar cpf no formato '999.999.999-99'" do
				f('22222222222').should eq '222.222.222-22'
			end		

			it "deve retornar cnpj no formato '99.999.999/9999-99'" do
				# http://www.geradorcnpj.com.br
				f('59384326000102').should eq '59.384.326/0001-02'
			end		

			it "deve retornar chave no formato '99 9999 99999999999999 99 999 999999999 9 99999999 9'" do
				f('99999999999999999999999999999999999999999988').should eq '99 9999 99999999999999 99 999 999999999 9 99999998 8'
			end					
		end # tam parametro
  end # f

  context "formatação data" do
  	it "deve retornar nil caso parâmetro seja nil" do
  		format_date(nil).should eq ''
  	end

  	pending "deve retornar data no formato '12/Abr/2012'" do
    	#load_path = Dir[File.expand_path(File.join(File.dirname(__FILE__), '/locales', 'pt-BR.yml')).to_s]
    	#I18n.load_path += load_path
    	#I18n.reload!
  		#I18n.default_locale = 'pt-BR'
  		format_date(Date.new(2012, 4, 12)).should eq '12/Abr/2012'
  	end
  end

  context "formatação numérica" do
  	context "número para moeda" do
	  	it "deve retornar '?' quando parâmetro for nil" do
	  		number_to_currency_br(nil).should eq '?'
	  	end

	  	it "deve retornar valor no formato 'R$ 999.999.999,99'" do
	  		number_to_currency_br(123456789.01).should eq 'R$ 123.456.789,01'
	  	end
  	end

  	context "número com delimitadores" do
	  	it "deve retornar '?' quando parâmetro for nil" do
	  		number_with_delimiter_br(nil).should eq '?'
	  	end

	  	it "deve retornar valor no formato '999.999.999.999'" do
	  		number_with_delimiter_br(879667876567).should eq '879.667.876.567'
	  	end
  	end
  end
end

describe "funções de busca de descrição" do
	it "deve retornar nil caso parâmetro código esteja vazio" do
		codigo_e_descricao('', {}).should be_nil
	end

	it "deve retornar nil caso parâmetro código seja nil" do
		codigo_e_descricao(nil, {}).should be_nil
	end

	it "deve retornar formatação 'cod - ?' caso não encontre código" do
		codigo_e_descricao('1', {}).should eq '1 - ?'
	end

	it "deve retornar '2 - Contribuinte pelo site do Fisco'" do
		codigo_e_descricao('2', ['nfe', 'processo_emissao']).should eq '2 - Contribuinte pelo site do Fisco'
	end

	it "deve retornar '04 - Entrada imune'" do
		codigo_e_descricao('04', ['nfe', 'ipi', 'cst']).should eq '04 - Entrada imune'
	end

	it "deve retornar '51 - ICMS diferido'" do
		codigo_e_descricao('51', ['nfe', 'icms', 'cst']).should eq '51 - ICMS diferido'
	end
end

describe "funções de render" do
	it "deve retornar vazio caso 'partial' esteja nil ou vazio" do
		render(nil).should eq ''

		render('').should eq ''
	end

	it "deve gerar exceção caso partial indique arquivo inexistente" do
 		expect {
			render('some_fake_file.abc')
		}.to raise_error(Errno::ENOENT)
	end

	it "deve retornar o mesmo texto enviado sem formatação HAML" do
		File.stub(:read).and_return('deve retornar o mesmo texto puro')    
		render('!').should eq "deve retornar o mesmo texto puro\n"
	end

	it "deve retornar texto HAML compilado em HTML" do
		File.stub(:read).and_return('%strong texto')    
		render('!').should eq "<strong>texto</strong>\n"
	end
end

describe RubyNfe::NfeToHtml do
	let(:xml) { load_fixture('nfe_fixture.xml') }

	it "deve instanciar um objeto NfeToHtml e 'parsear' o XML enviado" do
		nh = RubyNfe::NfeToHtml.new(xml)
		nh.should_not be_nil

		nh.xml.css('nfeProc NFe infNFe ide nNF').text.should eq '11199'
		nh.xml.at_xpath('//nfeProc/NFe/infNFe/emit/xFant').text.should eq 'Fic'
	end

	it "deve renderizar o documento para html" do
		nh = RubyNfe::NfeToHtml.new(xml)

		html = Nokogiri::HTML(nh.render_documento)
		html.css('section table tr td')[1].text.should eq '11.199'
	end

end

describe "render_nfe" do
	it "deve renderizar documento" do
		doc = render_nfe(load_fixture('nfe_fixture.xml'))

		html = Nokogiri::HTML(doc)

		html.css('section table tr td')[2].text.should eq '2.00'
		html.css('div#nfe-dados table tr td')[3].text.should eq 'R$ 696,49'
		html.css('div#nfe-dados table')[1].css('tr td')[2].text.should eq '666778899'
		html.css('div#nfe-dados table')[2].css('tr td')[0].text.should eq '64.331.363/0001-92'
		html.css('div#nfe-dados table')[3].css('tr td')[0].text.should eq '0 - Aplicativo do Contribuinte'

		html.css('div#nfe-emit table')[0].css('tr td')[0].text.should eq 'Empresa Ficticia Ltda'
		html.css('div#nfe-emit table')[0].css('tr')[3].css('td')[1].text.should eq 'Rua Brasil, 7788'
		html.css('div#nfe-emit table')[0].css('tr')[15].css('td')[1].text.should eq '3 - Regime Normal'

		html.css('div#nfe-dest table')[0].css('tr')[3].css('td')[0].text.should eq '64.331.363/0001-92'
		
		html.css('div#nfe-itens table')[0].css('tr')[2].css('td')[2].text.should eq '2,0000'
		
		html.css('div#nfe-totais table')[0].css('tr')[1].css('td')[1].text.should eq 'R$ 75,98'
		html.css('div#nfe-totais table')[0].css('tr')[5].css('td')[1].text.should eq 'R$ 696,49'
		
		html.css('div#nfe-transp table')[0].css('tr')[1].css('td')[0].text.should eq '1 - Por conta do destinatário/remetente'

		html.css('div#nfe-cobr table')[0].css('tr')[0].css('td')[0].text.should eq 'Não informada na NF-e'
		
	end
end