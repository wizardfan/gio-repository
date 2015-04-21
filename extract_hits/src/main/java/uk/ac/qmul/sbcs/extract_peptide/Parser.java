/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package uk.ac.qmul.sbcs.extract_peptide;

/**
 *
 * @author Jun Fan@qmul
 */
abstract public class Parser {
    String input;
    String output;

    abstract void parse();
}
