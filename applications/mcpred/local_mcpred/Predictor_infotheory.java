/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package local_mcpred;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;

/**
 *
 * @author mjfidcl2
 */
public class Predictor_infotheory {
    
    
    private String[] protnames;
    private HashMap<String, String> fasta;
    private HashMap<String, String[]> protpeps;
    private HashMap<String, String> pep_starts;
    private HashMap<String, String> pep_ends;
    private HashMap<String, String> classification;
    private HashMap<String, Double> cleaved;
    private HashMap<String, Double> mcleaved;
    
    public Predictor_infotheory(){
     //matrix information
       cleaved = new HashMap<String, Double>();
       cleaved.put("0_S", new Double(""+0.00155119425371577));
       cleaved.put("0_F", new Double(""+0.0101203450370329));
       cleaved.put("0_T", new Double(""+0.00437580160216219));
       cleaved.put("0_N", new Double(""+0.00863951037114175));
       cleaved.put("0_K", new Double(""+-0.0426349905702423));
       cleaved.put("0_x", new Double(""+0));
       cleaved.put("0_Y", new Double(""+-0.00523499887692041));
       cleaved.put("0_E", new Double(""+0.00818034396259026));
       cleaved.put("0_V", new Double(""+0.00493316169438667));
       cleaved.put("0_Z", new Double(""+0.0853437450703708));
       cleaved.put("0_Q", new Double(""+-0.00238950679147767));
       cleaved.put("0_M", new Double(""+0.00754132801219614));
       cleaved.put("0_C", new Double(""+0.01095597703868));
       cleaved.put("0_L", new Double(""+0.00188686459291307));
       cleaved.put("0_A", new Double(""+-0.0049122447091631));
       cleaved.put("0_W", new Double(""+0.00693320815473958));
       cleaved.put("0_X", new Double(""+-0.011566267937686));
       cleaved.put("0_P", new Double(""+0.0103237181563291));
       cleaved.put("0_Ct", new Double(""+0));
       cleaved.put("0_B", new Double(""+0.0853437450703708));
       cleaved.put("0_H", new Double(""+0.00578955397457641));
       cleaved.put("0_D", new Double(""+0.0141624132472289));
       cleaved.put("0_I", new Double(""+0.00384378298672882));
       cleaved.put("0_R", new Double(""+-0.0559191548111558));
       cleaved.put("0_G", new Double(""+-0.000318027050528464));
       cleaved.put("0_Nt", new Double(""+0.0809346261653139));

       cleaved.put("1_S", new Double(""+-0.00188774397621617));
       cleaved.put("1_F", new Double(""+0.0144613722136596));
       cleaved.put("1_T", new Double(""+0.00526322191736816));
       cleaved.put("1_N", new Double(""+0.0111926226367841));
       cleaved.put("1_K", new Double(""+-0.044153635141278));
       cleaved.put("1_x", new Double(""+0));
       cleaved.put("1_Y", new Double(""+0.0152488432689032));
       cleaved.put("1_E", new Double(""+-0.00222127914039957));
       cleaved.put("1_V", new Double(""+0.00417320066605687));
       cleaved.put("1_Z", new Double(""+0.0853437450703708));
       cleaved.put("1_Q", new Double(""+0.00636975003212183));
       cleaved.put("1_M", new Double(""+-0.00524147923293532));
       cleaved.put("1_C", new Double(""+0.0148254346379286));
       cleaved.put("1_L", new Double(""+0.00508630706016019));
       cleaved.put("1_A", new Double(""+-0.00626781185306248));
       cleaved.put("1_W", new Double(""+0.0181272910523906));
       cleaved.put("1_X", new Double(""+-0.090747513985311));
       cleaved.put("1_P", new Double(""+0.0150543502357306));
       cleaved.put("1_Ct", new Double(""+0));
       cleaved.put("1_B", new Double(""+0.0853437450703708));
       cleaved.put("1_H", new Double(""+0.00455527468070269));
       cleaved.put("1_D", new Double(""+0.0099568688324829));
       cleaved.put("1_I", new Double(""+0.00131189125848209));
       cleaved.put("1_R", new Double(""+-0.0455394380519306));
       cleaved.put("1_G", new Double(""+0.000868058270173546));
       cleaved.put("1_Nt", new Double(""+0.0688146873864017));

       cleaved.put("2_S", new Double(""+-0.00179609780733301));
       cleaved.put("2_F", new Double(""+0.0280184052564126));
       cleaved.put("2_T", new Double(""+-0.0022521384724719));
       cleaved.put("2_N", new Double(""+0.010514806562435));
       cleaved.put("2_K", new Double(""+-0.0498530534413316));
       cleaved.put("2_x", new Double(""+0));
       cleaved.put("2_Y", new Double(""+0.0194801608035318));
       cleaved.put("2_E", new Double(""+0.0028442937155881));
       cleaved.put("2_V", new Double(""+0.00917321806055152));
       cleaved.put("2_Z", new Double(""+0.0853437450703708));
       cleaved.put("2_Q", new Double(""+0.012161600167981));
       cleaved.put("2_M", new Double(""+0.0057657018440194));
       cleaved.put("2_C", new Double(""+0.0219373168460715));
       cleaved.put("2_L", new Double(""+0.0015271894185259));
       cleaved.put("2_A", new Double(""+-0.00113516316915836));
       cleaved.put("2_W", new Double(""+0.0254494100003613));
       cleaved.put("2_X", new Double(""+0.0183969554397552));
       cleaved.put("2_P", new Double(""+0.00487552628651554));
       cleaved.put("2_Ct", new Double(""+0));
       cleaved.put("2_H", new Double(""+0.020885755843452));
       cleaved.put("2_D", new Double(""+0.000929377266564833));
       cleaved.put("2_I", new Double(""+-0.000352115411225422));
       cleaved.put("2_R", new Double(""+-0.0541455813655727));
       cleaved.put("2_G", new Double(""+0.000330198733098511));
       cleaved.put("2_Nt", new Double(""+-0.00598639055684963));

       cleaved.put("3_S", new Double(""+0.00120217171057805));
       cleaved.put("3_F", new Double(""+0.0181982754958097));
       cleaved.put("3_T", new Double(""+0.00746782714495857));
       cleaved.put("3_N", new Double(""+0.000459581898316416));
       cleaved.put("3_K", new Double(""+-0.0497578863798243));
       cleaved.put("3_x", new Double(""+0));
       cleaved.put("3_Y", new Double(""+0.0168451463172139));
       cleaved.put("3_E", new Double(""+0.00491926832574982));
       cleaved.put("3_V", new Double(""+0.00952970722162894));
       cleaved.put("3_Z", new Double(""+0.0853437450703708));
       cleaved.put("3_Q", new Double(""+0.0104019447570531));
       cleaved.put("3_M", new Double(""+-0.0101222284297051));
       cleaved.put("3_C", new Double(""+0.0112312454730355));
       cleaved.put("3_L", new Double(""+0.000930249394099852));
       cleaved.put("3_A", new Double(""+0.00392961759045261));
       cleaved.put("3_W", new Double(""+0.0354451553685568));
       cleaved.put("3_X", new Double(""+0.0853437450703708));
       cleaved.put("3_P", new Double(""+0.0258005600513561));
       cleaved.put("3_Ct", new Double(""+0));
       cleaved.put("3_H", new Double(""+0.00594142776223056));
       cleaved.put("3_D", new Double(""+-0.0162973823115694));
       cleaved.put("3_I", new Double(""+0.00565904209703786));
       cleaved.put("3_R", new Double(""+-0.0538609149609292));
       cleaved.put("3_G", new Double(""+-0.00346452584212206));
       cleaved.put("3_Nt", new Double(""+-0.190862666868579));

       cleaved.put("4_S", new Double(""+0));
       cleaved.put("4_F", new Double(""+0));
       cleaved.put("4_T", new Double(""+0));
       cleaved.put("4_N", new Double(""+0));
       cleaved.put("4_K", new Double(""+-0.0106125875004242));
       cleaved.put("4_x", new Double(""+0));
       cleaved.put("4_Y", new Double(""+0));
       cleaved.put("4_E", new Double(""+0));
       cleaved.put("4_V", new Double(""+0));
       cleaved.put("4_Z", new Double(""+0));
       cleaved.put("4_Q", new Double(""+0));
       cleaved.put("4_M", new Double(""+0));
       cleaved.put("4_C", new Double(""+0));
       cleaved.put("4_L", new Double(""+0));
       cleaved.put("4_A", new Double(""+0));
       cleaved.put("4_W", new Double(""+0));
       cleaved.put("4_X", new Double(""+0));
       cleaved.put("4_P", new Double(""+0));
       cleaved.put("4_Ct", new Double(""+0));
       cleaved.put("4_H", new Double(""+0));
       cleaved.put("4_D", new Double(""+0));
       cleaved.put("4_I", new Double(""+0));
       cleaved.put("4_R", new Double(""+0.0112126601842253));
       cleaved.put("4_G", new Double(""+0));
       cleaved.put("4_Nt", new Double(""+0));

       cleaved.put("5_S", new Double(""+-0.00414728931498034));
       cleaved.put("5_F", new Double(""+0.0119920426834694));
       cleaved.put("5_T", new Double(""+0.0115728837855243));
       cleaved.put("5_N", new Double(""+0.0153786428896758));
       cleaved.put("5_K", new Double(""+0.00402270759345742));
       cleaved.put("5_x", new Double(""+0));
       cleaved.put("5_Y", new Double(""+0.0194284810017644));
       cleaved.put("5_E", new Double(""+-0.0124248587558356));
       cleaved.put("5_V", new Double(""+0.00681194613657833));
       cleaved.put("5_Z", new Double(""+0.0853437450703708));
       cleaved.put("5_Q", new Double(""+0.0218723992037776));
       cleaved.put("5_M", new Double(""+0.0212654895269526));
       cleaved.put("5_C", new Double(""+0.0173071318266984));
       cleaved.put("5_L", new Double(""+0.0147945517930332));
       cleaved.put("5_A", new Double(""+0.0186237213392114));
       cleaved.put("5_W", new Double(""+0.0306856368818309));
       cleaved.put("5_X", new Double(""+-0.0395949915379296));
       cleaved.put("5_P", new Double(""+-1.408135429711));
       cleaved.put("5_Ct", new Double(""+0.0853437450703708));
       cleaved.put("5_H", new Double(""+0.0117663765407453));
       cleaved.put("5_D", new Double(""+-0.007133815548037));
       cleaved.put("5_I", new Double(""+0.0199421197114211));
       cleaved.put("5_R", new Double(""+-0.0206030273840874));
       cleaved.put("5_G", new Double(""+0.0000820312810020782));
       cleaved.put("5_Nt", new Double(""+0));

       cleaved.put("6_S", new Double(""+-0.00607359115820411));
       cleaved.put("6_F", new Double(""+0.0139395144782525));
       cleaved.put("6_T", new Double(""+0.00871709724548706));
       cleaved.put("6_N", new Double(""+-0.00122862317011291));
       cleaved.put("6_K", new Double(""+-0.0148551046432945));
       cleaved.put("6_x", new Double(""+0));
       cleaved.put("6_Y", new Double(""+0.0127667737830556));
       cleaved.put("6_E", new Double(""+-0.0232307606334326));
       cleaved.put("6_V", new Double(""+0.0173429094275379));
       cleaved.put("6_Z", new Double(""+0.0853437450703708));
       cleaved.put("6_Q", new Double(""+0.0101618904516775));
       cleaved.put("6_M", new Double(""+-0.0087793419126029));
       cleaved.put("6_C", new Double(""+0.0182362544270455));
       cleaved.put("6_L", new Double(""+0.00748424375471079));
       cleaved.put("6_A", new Double(""+0.00420022515410901));
       cleaved.put("6_W", new Double(""+0.00282917821310596));
       cleaved.put("6_X", new Double(""+0.00616249902274598));
       cleaved.put("6_P", new Double(""+-0.0151176661385177));
       cleaved.put("6_Ct", new Double(""+-0.0332362471694817));
       cleaved.put("6_H", new Double(""+0.0184516214958325));
       cleaved.put("6_D", new Double(""+-0.0118184470690743));
       cleaved.put("6_I", new Double(""+0.0138750181207925));
       cleaved.put("6_R", new Double(""+-0.0245971841699276));
       cleaved.put("6_G", new Double(""+-0.00290995754241101));
       cleaved.put("6_Nt", new Double(""+0));

       cleaved.put("7_S", new Double(""+0.00688957312924048));
       cleaved.put("7_F", new Double(""+0.00468781345674047));
       cleaved.put("7_T", new Double(""+0.00208777500908572));
       cleaved.put("7_N", new Double(""+0.00644852823507257));
       cleaved.put("7_K", new Double(""+-0.0267866580116544));
       cleaved.put("7_x", new Double(""+0));
       cleaved.put("7_Y", new Double(""+0.00498714111480968));
       cleaved.put("7_E", new Double(""+0.00181031130741747));
       cleaved.put("7_V", new Double(""+0.00479136512294075));
       cleaved.put("7_Z", new Double(""+0.0853437450703708));
       cleaved.put("7_Q", new Double(""+0.0109962160318145));
       cleaved.put("7_M", new Double(""+-0.013142656172641));
       cleaved.put("7_C", new Double(""+0.0058884097224481));
       cleaved.put("7_L", new Double(""+0.00219706314393281));
       cleaved.put("7_A", new Double(""+0.0000353002332739628));
       cleaved.put("7_W", new Double(""+0.00730387808155344));
       cleaved.put("7_X", new Double(""+-0.0395949915379296));
       cleaved.put("7_P", new Double(""+0.000582621641907323));
       cleaved.put("7_Ct", new Double(""+-0.00965307329340537));
       cleaved.put("7_H", new Double(""+0.0133219958800885));
       cleaved.put("7_D", new Double(""+0.00654705296026112));
       cleaved.put("7_I", new Double(""+0.00102285937033262));
       cleaved.put("7_R", new Double(""+-0.0427821442802085));
       cleaved.put("7_G", new Double(""+0.000209352903511755));
       cleaved.put("7_Nt", new Double(""+0));

       cleaved.put("8_S", new Double(""+-0.00101967408837821));
       cleaved.put("8_F", new Double(""+0.00297659657226406));
       cleaved.put("8_T", new Double(""+0.00000377150826628033));
       cleaved.put("8_N", new Double(""+0.0143452805729061));
       cleaved.put("8_K", new Double(""+-0.043014650796067));
       cleaved.put("8_x", new Double(""+0));
       cleaved.put("8_Y", new Double(""+0.00476543997301542));
       cleaved.put("8_E", new Double(""+0.00716014784841427));
       cleaved.put("8_V", new Double(""+0.00825865300614361));
       cleaved.put("8_Z", new Double(""+0.0853437450703708));
       cleaved.put("8_Q", new Double(""+0.00779255049091823));
       cleaved.put("8_M", new Double(""+-0.00273285530984907));
       cleaved.put("8_C", new Double(""+0.00192544607949062));
       cleaved.put("8_L", new Double(""+0.00457080341133138));
       cleaved.put("8_A", new Double(""+0.00133092924208546));
       cleaved.put("8_W", new Double(""+0.0120257729838156));
       cleaved.put("8_X", new Double(""+-0.0395949915379296));
       cleaved.put("8_P", new Double(""+0.00559968095391454));
       cleaved.put("8_Ct", new Double(""+0.0276120364797184));
       cleaved.put("8_H", new Double(""+0.00914181836068942));
       cleaved.put("8_D", new Double(""+0.0067050281150376));
       cleaved.put("8_I", new Double(""+0.00455976059407499));
       cleaved.put("8_R", new Double(""+-0.0566332092070675));
       cleaved.put("8_G", new Double(""+0.00371362222983421));
       cleaved.put("8_Nt", new Double(""+0));

       mcleaved = new HashMap<String, Double>();
       mcleaved.put("0_S", new Double(""+-0.00721584368297066));
       mcleaved.put("0_F", new Double(""+-0.0499143795822267));
       mcleaved.put("0_T", new Double(""+-0.0207404654555115));
       mcleaved.put("0_N", new Double(""+-0.0421668411875381));
       mcleaved.put("0_K", new Double(""+0.155520296424895));
       mcleaved.put("0_x", new Double(""+0));
       mcleaved.put("0_Y", new Double(""+0.0233253947565591));
       mcleaved.put("0_E", new Double(""+-0.039797629165997));
       mcleaved.put("0_V", new Double(""+-0.0234703056642569));
       mcleaved.put("0_Z", new Double(""+0));
       mcleaved.put("0_Q", new Double(""+0.0108374287670045));
       mcleaved.put("0_M", new Double(""+-0.0365259139536316));
       mcleaved.put("0_C", new Double(""+-0.0543599833494246));
       mcleaved.put("0_L", new Double(""+-0.00879665556808435));
       mcleaved.put("0_A", new Double(""+0.0219309154288239));
       mcleaved.put("0_W", new Double(""+-0.0334395263233619));
       mcleaved.put("0_X", new Double(""+0.0496159156380304));
       mcleaved.put("0_P", new Double(""+-0.0509913667336383));
       mcleaved.put("0_Ct", new Double(""+0));
       mcleaved.put("0_B", new Double(""+0));
       mcleaved.put("0_H", new Double(""+-0.0277053940254705));
       mcleaved.put("0_D", new Double(""+-0.0719369441334252));
       mcleaved.put("0_I", new Double(""+-0.0181538887728747));
       mcleaved.put("0_R", new Double(""+0.192111114311861));
       mcleaved.put("0_G", new Double(""+0.00146155865238389));
       mcleaved.put("0_Nt", new Double(""+-1.2470492746235));

       //here
       mcleaved.put("1_S", new Double(""+0.00858895217038756));
       mcleaved.put("1_F", new Double(""+-0.0736193995313521));
       mcleaved.put("1_T", new Double(""+-0.0250966660897753));
       mcleaved.put("1_N", new Double(""+-0.0556288300737603));
       mcleaved.put("1_K", new Double(""+0.159921600947166));
       mcleaved.put("1_x", new Double(""+0));
       mcleaved.put("1_Y", new Double(""+-0.0780881261688707));
       mcleaved.put("1_E", new Double(""+0.0100851603709803));
       mcleaved.put("1_V", new Double(""+-0.0197532660165449));
       mcleaved.put("1_Z", new Double(""+0));
       mcleaved.put("1_Q", new Double(""+-0.0306030716008546));
       mcleaved.put("1_M", new Double(""+0.0233533371391882));
       mcleaved.put("1_C", new Double(""+-0.075678654240404));
       mcleaved.put("1_L", new Double(""+-0.0242240132320469));
       mcleaved.put("1_A", new Double(""+0.0277509980548175));
       mcleaved.put("1_W", new Double(""+-0.0948976405530249));
       mcleaved.put("1_X", new Double(""+0.271464665254386));
       mcleaved.put("1_P", new Double(""+-0.0769793817145727));
       mcleaved.put("1_Ct", new Double(""+0));
       mcleaved.put("1_B", new Double(""+0));
       mcleaved.put("1_H", new Double(""+-0.021617235705912));
       mcleaved.put("1_D", new Double(""+-0.0490509678757512));
       mcleaved.put("1_I", new Double(""+-0.00609311139032893));
       mcleaved.put("1_R", new Double(""+0.163886132848834));
       mcleaved.put("1_G", new Double(""+-0.00402007022809444));
       mcleaved.put("1_Nt", new Double(""+-0.679188613161495));

       mcleaved.put("2_S", new Double(""+0.00817672965188891));
       mcleaved.put("2_F", new Double(""+-0.159199188226274));
       mcleaved.put("2_T", new Double(""+0.0102232743918174));
       mcleaved.put("2_N", new Double(""+-0.05200619945784));
       mcleaved.put("2_K", new Double(""+0.175921830105783));
       mcleaved.put("2_x", new Double(""+0));
       mcleaved.put("2_Y", new Double(""+-0.103068708688225));
       mcleaved.put("2_E", new Double(""+-0.0133442628224803));
       mcleaved.put("2_V", new Double(""+-0.0449401919765487));
       mcleaved.put("2_Z", new Double(""+0));
       mcleaved.put("2_Q", new Double(""+-0.0608706268016039));
       mcleaved.put("2_M", new Double(""+-0.0275867644275067));
       mcleaved.put("2_C", new Double(""+-0.118382665495958));
       mcleaved.put("2_L", new Double(""+-0.00710306174657736));
       mcleaved.put("2_A", new Double(""+0.00518962066798522));
       mcleaved.put("2_W", new Double(""+-0.141415693210588));
       mcleaved.put("2_X", new Double(""+-0.0965121200402077));
       mcleaved.put("2_P", new Double(""+-0.0231870591559591));
       mcleaved.put("2_Ct", new Double(""+0));
       mcleaved.put("2_H", new Double(""+-0.111752086596945));
       mcleaved.put("2_D", new Double(""+-0.00430576272835574));
       mcleaved.put("2_I", new Double(""+0.00161786388127948));
       mcleaved.put("2_R", new Double(""+0.187463071487379));
       mcleaved.put("2_G", new Double(""+-0.00152385762818177));
       mcleaved.put("2_Nt", new Double(""+0.0265506115693381));

       mcleaved.put("3_S", new Double(""+-0.00557951790496735));
       mcleaved.put("3_F", new Double(""+-0.0953219453246492));
       mcleaved.put("3_T", new Double(""+-0.0361514776936105));
       mcleaved.put("3_N", new Double(""+-0.00212273527092521));
       mcleaved.put("3_K", new Double(""+0.175661135601301));
       mcleaved.put("3_x", new Double(""+0));
       mcleaved.put("3_Y", new Double(""+-0.0873159356295266));
       mcleaved.put("3_E", new Double(""+-0.0234020070165263));
       mcleaved.put("3_V", new Double(""+-0.0468044755798308));
       mcleaved.put("3_Z", new Double(""+0));
       mcleaved.put("3_Q", new Double(""+-0.05140647211982));
       mcleaved.put("3_M", new Double(""+0.0437912585812453));
       mcleaved.put("3_C", new Double(""+-0.055836336165553));
       mcleaved.put("3_L", new Double(""+-0.00430982772116158));
       mcleaved.put("3_A", new Double(""+-0.0185699461081312));
       mcleaved.put("3_W", new Double(""+-0.215820560584245));
       mcleaved.put("3_X", new Double(""+0));
       mcleaved.put("3_P", new Double(""+-0.143797826856209));
       mcleaved.put("3_Ct", new Double(""+0));
       mcleaved.put("3_H", new Double(""+-0.0284616589594472));
       mcleaved.put("3_D", new Double(""+0.0680412256217175));
       mcleaved.put("3_I", new Double(""+-0.0270567632506103));
       mcleaved.put("3_R", new Double(""+0.186710603099994));
       mcleaved.put("3_G", new Double(""+0.0156073024880689));
       mcleaved.put("3_Nt", new Double(""+0.421226985587719));

       mcleaved.put("4_S", new Double(""+0));
       mcleaved.put("4_F", new Double(""+0));
       mcleaved.put("4_T", new Double(""+0));
       mcleaved.put("4_N", new Double(""+0));
       mcleaved.put("4_K", new Double(""+0.045780112741825));
       mcleaved.put("4_x", new Double(""+0));
       mcleaved.put("4_Y", new Double(""+0));
       mcleaved.put("4_E", new Double(""+0));
       mcleaved.put("4_V", new Double(""+0));
       mcleaved.put("4_Z", new Double(""+0));
       mcleaved.put("4_Q", new Double(""+0));
       mcleaved.put("4_M", new Double(""+0));
       mcleaved.put("4_C", new Double(""+0));
       mcleaved.put("4_L", new Double(""+0));
       mcleaved.put("4_A", new Double(""+0));
       mcleaved.put("4_W", new Double(""+0));
       mcleaved.put("4_X", new Double(""+0));
       mcleaved.put("4_P", new Double(""+0));
       mcleaved.put("4_Ct", new Double(""+0));
       mcleaved.put("4_H", new Double(""+0));
       mcleaved.put("4_D", new Double(""+0));
       mcleaved.put("4_I", new Double(""+0));
       mcleaved.put("4_R", new Double(""+-0.0557364696622383));
       mcleaved.put("4_G", new Double(""+0));
       mcleaved.put("4_Nt", new Double(""+0));

       mcleaved.put("5_S", new Double(""+0.0186037055032237));
       mcleaved.put("5_F", new Double(""+-0.0599479594033155));
       mcleaved.put("5_T", new Double(""+-0.0576769689205623));
       mcleaved.put("5_N", new Double(""+-0.0788299287119621));
       mcleaved.put("5_K", new Double(""+-0.0190217159063933));
       mcleaved.put("5_x", new Double(""+0));
       mcleaved.put("5_Y", new Double(""+-0.1027532603019));
       mcleaved.put("5_E", new Double(""+0.053033404763815));
       mcleaved.put("5_V", new Double(""+-0.0328272141698239));
       mcleaved.put("5_Z", new Double(""+0));
       mcleaved.put("5_Q", new Double(""+-0.117969916479998));
       mcleaved.put("5_M", new Double(""+-0.114132974344623));
       mcleaved.put("5_C", new Double(""+-0.0900299925122872));
       mcleaved.put("5_L", new Double(""+-0.0755035242375552));
       mcleaved.put("5_A", new Double(""+-0.0978752075888718));
       mcleaved.put("5_W", new Double(""+-0.178586262592309));
       mcleaved.put("5_X", new Double(""+0.146525928646086));
       mcleaved.put("5_P", new Double(""+0.734415886060518));
       mcleaved.put("5_Ct", new Double(""+0));
       mcleaved.put("5_H", new Double(""+-0.0587235591508078));
       mcleaved.put("5_D", new Double(""+0.0314193812682074));
       mcleaved.put("5_I", new Double(""+-0.105900364403556));
       mcleaved.put("5_R", new Double(""+0.0839923310796518));
       mcleaved.put("5_G", new Double(""+0.000377565111733786));
       mcleaved.put("5_Nt", new Double(""+0));

       mcleaved.put("6_S", new Double(""+0.026922998856415));
       mcleaved.put("6_F", new Double(""+-0.0706875113660484));
       mcleaved.put("6_T", new Double(""+-0.0425687027718217));
       mcleaved.put("6_N", new Double(""+0.00561354121363955));
       mcleaved.put("6_K", new Double(""+0.0625277225670337));
       mcleaved.put("6_x", new Double(""+0));
       mcleaved.put("6_Y", new Double(""+-0.0641827923770768));
       mcleaved.put("6_E", new Double(""+0.0933726218622424));
       mcleaved.put("6_V", new Double(""+-0.0902410077930348));
       mcleaved.put("6_Z", new Double(""+0));
       mcleaved.put("6_Q", new Double(""+-0.0501341304713985));
       mcleaved.put("6_M", new Double(""+0.0382858518051329));
       mcleaved.put("6_C", new Double(""+-0.0955491607057649));
       mcleaved.put("6_L", new Double(""+-0.0362350755152361));
       mcleaved.put("6_A", new Double(""+-0.0198847901320386));
       mcleaved.put("6_W", new Double(""+-0.0132720175157153));
       mcleaved.put("6_X", new Double(""+-0.0295653304095948));
       mcleaved.put("6_P", new Double(""+0.0635380307218723));
       mcleaved.put("6_Ct", new Double(""+0.126871240649617));
       mcleaved.put("6_H", new Double(""+-0.0968402609563878));
       mcleaved.put("6_D", new Double(""+0.0506231703962375));
       mcleaved.put("6_I", new Double(""+-0.0703267734771773));
       mcleaved.put("6_R", new Double(""+0.098149568952218));
       mcleaved.put("6_G", new Double(""+0.0131546928606713));
       mcleaved.put("6_Nt", new Double(""+0));

       mcleaved.put("7_S", new Double(""+-0.0332190722669007));
       mcleaved.put("7_F", new Double(""+-0.0222660916680952));
       mcleaved.put("7_T", new Double(""+-0.00974617373848127));
       mcleaved.put("7_N", new Double(""+-0.0309983090244586));
       mcleaved.put("7_K", new Double(""+0.105665409640322));
       mcleaved.put("7_x", new Double(""+0));
       mcleaved.put("7_Y", new Double(""+-0.0237357867488708));
       mcleaved.put("7_E", new Double(""+-0.00843551965998847));
       mcleaved.put("7_V", new Double(""+-0.0227738520402987));
       mcleaved.put("7_Z", new Double(""+0));
       mcleaved.put("7_Q", new Double(""+-0.0545754266914563));
       mcleaved.put("7_M", new Double(""+0.0558648649150308));
       mcleaved.put("7_C", new Double(""+-0.0281974726429136));
       mcleaved.put("7_L", new Double(""+-0.0102637359244067));
       mcleaved.put("7_A", new Double(""+-0.000162599309729288));
       mcleaved.put("7_W", new Double(""+-0.0353176592986856));
       mcleaved.put("7_X", new Double(""+0.146525928646086));
       mcleaved.put("7_P", new Double(""+-0.00269318400929317));
       mcleaved.put("7_Ct", new Double(""+0.0418777246061289));
       mcleaved.put("7_H", new Double(""+-0.0672480561621474));
       mcleaved.put("7_D", new Double(""+-0.0314932243949499));
       mcleaved.put("7_I", new Double(""+-0.00474174668456256));
       mcleaved.put("7_R", new Double(""+0.15594940772927));
       mcleaved.put("7_G", new Double(""+-0.000965402581785676));
       mcleaved.put("7_Nt", new Double(""+0));

       mcleaved.put("8_S", new Double(""+0.00466508103872825));
       mcleaved.put("8_F", new Double(""+-0.0139772319849951));
       mcleaved.put("8_T", new Double(""+-0.0000173687197929421));
       mcleaved.put("8_N", new Double(""+-0.0729651571272533));
       mcleaved.put("8_K", new Double(""+0.156626255550412));
       mcleaved.put("8_x", new Double(""+0));
       mcleaved.put("8_Y", new Double(""+-0.0226466622914581));
       mcleaved.put("8_E", new Double(""+-0.0345882434083597));
       mcleaved.put("8_V", new Double(""+-0.0402005991445456));
       mcleaved.put("8_Z", new Double(""+0));
       mcleaved.put("8_Q", new Double(""+-0.0378086424322195));
       mcleaved.put("8_M", new Double(""+0.0123678582184007));
       mcleaved.put("8_C", new Double(""+-0.00897879962781697));
       mcleaved.put("8_L", new Double(""+-0.0216931977051885));
       mcleaved.put("8_A", new Double(""+-0.00618230263814537));
       mcleaved.put("8_W", new Double(""+-0.0601313220751986));
       mcleaved.put("8_X", new Double(""+0.146525928646086));
       mcleaved.put("8_P", new Double(""+-0.0267621290007437));
       mcleaved.put("8_Ct", new Double(""+-0.156330115182119));
       mcleaved.put("8_H", new Double(""+-0.0447764411487796));
       mcleaved.put("8_D", new Double(""+-0.0322881887450678));
       mcleaved.put("8_I", new Double(""+-0.0216391778358078));
       mcleaved.put("8_R", new Double(""+0.193963194795178));
       mcleaved.put("8_G", new Double(""+-0.0175238898661841));
       mcleaved.put("8_Nt", new Double(""+0));
    
    }
    
    
    public void importPeptides(HashMap<String, String[]> pephash, HashMap<String, String> prots){
        this.fasta = prots;
        this.protpeps = pephash;
        this.protnames = new String[pephash.size()];
        protpeps.keySet().toArray(protnames);                
    }
    
    public void runClassification(){    
        pep_starts = new HashMap<String, String>();
        pep_ends = new HashMap<String, String>();  
        
        for(int i=0;i<protnames.length;i++){
            
            String[] peps = protpeps.get(protnames[i]);            
            int last = 0;
            
            for(int j=0;j<peps.length;j++){
                int start = fasta.get(protnames[i]).indexOf(peps[j],last);
                int end = fasta.get(protnames[i]).indexOf(peps[j],last)+peps[j].length();
                last = fasta.get(protnames[i]).indexOf(peps[j], last)+peps[j].length();
                        
                if(start == 0){
                    pep_starts.put(protnames[i] + "_" + peps[j]+"_"+j, "--");   
                }else if((start+4)> fasta.get(protnames[i]).length()){           
                    int diff = (start+4) - fasta.get(protnames[i]).length();    
                    pep_starts.put(protnames[i] + "_" + peps[j]+"_"+j,fasta.get(protnames[i]).substring(start-5)+McpredUtils.addZ(diff)); 
                }else if (start < 5) {
                    int diff = 5 - start;
                    pep_starts.put(protnames[i] + "_" + peps[j]+"_"+j, McpredUtils.addZ(diff) + "" + fasta.get(protnames[i]).substring(0, start + 4));
                }else {
                    pep_starts.put(protnames[i] + "_" + peps[j]+"_"+j, fasta.get(protnames[i]).substring(start - 5, start + 4));
                }

                if(end == fasta.get(protnames[i]).length()){
                    pep_ends.put(protnames[i] + "_" + peps[j]+"_"+j, "--");
                }else if((end-5)<0){
                    int diff = 0-(end-5);
                    pep_ends.put(protnames[i] + "_" + peps[j]+"_"+j,McpredUtils.addZ(diff)+""+fasta.get(protnames[i]).substring(0, end+4));
                }else if(fasta.get(protnames[i]).length() < (4+end)){
                    int diff = (4+end)-fasta.get(protnames[i]).length();
                    pep_ends.put(protnames[i] + "_" + peps[j]+"_"+j, fasta.get(protnames[i]).substring(end - 5) + "" + McpredUtils.addZ(diff));
                }else{
                    pep_ends.put(protnames[i] + "_" + peps[j]+"_"+j, fasta.get(protnames[i]).substring(end - 5, end + 4));
                }
            }
        }
        
       classification = new HashMap<String, String>();
       DecimalFormat df = new DecimalFormat("0.00");
       
       
       for(int i=0;i<protnames.length;i++){
           String[] peps = protpeps.get(protnames[i]);
           for(int j=0;j<peps.length;j++){
               //check invalid amino acid characters in tryptic context
                
                String start_contains = "";
                String end_contains = "";
                String[] start_pepcheck = pep_starts.get(protnames[i]+"_"+peps[j]+"_"+j).split("");
                String[] end_pepcheck = pep_ends.get(protnames[i]+"_"+peps[j]+"_"+j).split("");
                
                ArrayList<String> valid = new ArrayList<String>();
                valid.add("G");
                valid.add("A");
                valid.add("S");
                valid.add("P");
                valid.add("V");
                valid.add("T");
                valid.add("C");
                valid.add("I");
                valid.add("L");
                valid.add("N");
                valid.add("D");
                valid.add("Q");
                valid.add("K");
                valid.add("E");
                valid.add("M");
                valid.add("H");
                valid.add("F");
                valid.add("R");
                valid.add("Y");
                valid.add("W");
                valid.add("Z");
                                
                for(int k=1;k<start_pepcheck.length;k++){
                    if(!valid.contains(start_pepcheck[k])){
                        start_contains += " "+start_pepcheck[k];
                    }
                }
                
                for(int k=1;k<end_pepcheck.length;k++){
                    if(!valid.contains(end_pepcheck[k])){
                        end_contains += " "+end_pepcheck[k];
                    }
                }
                    
                if (!pep_starts.get(protnames[i] + "_" + peps[j]+"_"+j).equals("--") && start_contains.equals("")) {
                    double miss = 0.0;
                    double cleave = 0.0;
                    String[] aa = pep_starts.get(protnames[i]+"_"+peps[j]+"_"+j).split("");
                    for(int p=0;p<aa.length-1;p++){                        
                        if(aa[p+1].equals("Z") && aa[1].equals("Z")){
                            miss += mcleaved.get(p+"_Nt").doubleValue();
                            cleave += cleaved.get(p+"_Nt").doubleValue();
                        }else if(aa[p+1].equals("Z") && aa[aa.length-1].equals("Z")){
                            miss += mcleaved.get(p+"_Ct").doubleValue();
                            cleave += cleaved.get(p+"_Ct").doubleValue();
                        } else {
                            miss += mcleaved.get(p+"_"+aa[p+1]).doubleValue();
                            cleave += cleaved.get(p+"_"+aa[p+1]).doubleValue();
                        }
                    }
                    classification.put("start_"+protnames[i]+"_"+peps[j]+"_"+j, df.format(miss-cleave));
                }else if(pep_starts.get(protnames[i] + "_" + peps[j]+"_"+j).equals("--")){
                    classification.put("start_"+protnames[i]+"_"+peps[j]+"_"+j, "--");
                }else if(!start_contains.equals("")){
                    classification.put("start_"+protnames[i]+"_"+peps[j]+"_"+j, "unknown amino acid ("+start_contains+" ) in N-terminal tryptic context");
                }
                
                
                
                
                if (!pep_ends.get(protnames[i] + "_" + peps[j]+"_"+j).equals("--") && end_contains.equals("")) {
                    double miss = 0.0;
                    double cleave = 0.0;
                    String[] aa = pep_ends.get(protnames[i]+"_"+peps[j]+"_"+j).split("");
                    for(int p=0;p<aa.length-1;p++){
                        if(aa[p+1].equals("Z") && aa[1].equals("Z")){
                            miss += mcleaved.get(p+"_Nt").doubleValue();
                            cleave += cleaved.get(p+"_Nt").doubleValue();
                        }else if(aa[p+1].equals("Z") && aa[aa.length-1].equals("Z")){
                            miss += mcleaved.get(p+"_Ct").doubleValue();
                            cleave += cleaved.get(p+"_Ct").doubleValue();
                        } else {
                            miss += mcleaved.get(p+"_"+aa[p+1]).doubleValue();
                            cleave += cleaved.get(p+"_"+aa[p+1]).doubleValue();
                        }
                    }
                    classification.put("end_" + protnames[i] + "_" + peps[j]+"_"+j, df.format(miss-cleave));
                } else if (pep_ends.get(protnames[i] + "_" + peps[j]+"_"+j).equals("--")) {
                    classification.put("end_" + protnames[i] + "_" + peps[j]+"_"+j, "--");
                } else if(!end_contains.equals("")){
                    classification.put("end_" + protnames[i] + "_" + peps[j]+"_"+j,"unknown amino acid ("+end_contains+" ) in C-terminal tryptic context");
                }
                                
           }
       }

    }
    
    
    public void printResults(){
        
        System.out.println("Protein\tPeptide\tN-Terminal\tC-Terminal");
        
        for(int i=0;i<protnames.length;i++){
            String[] peps = protpeps.get(protnames[i]);
            for(int j=0;j<peps.length;j++){
                System.out.println(protnames[i]+"\t"+peps[j]+"\t"+classification.get("start_"+protnames[i]+"_"+peps[j]+"_"+j)+"\t"+classification.get("end_"+protnames[i]+"_"+peps[j]+"_"+j));
            }
        }
    }
    
    
}
